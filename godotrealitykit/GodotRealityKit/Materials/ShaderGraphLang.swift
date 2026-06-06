//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc.
//
// Licensed under the MIT license (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// LICENSE
//
//===----------------------------------------------------------------------===//

import Foundation
import RealityKit

fileprivate class NodeDefParserDelegate: NSObject, XMLParserDelegate {
    var verbose = false
    var nodeDefs = [String: NodeDef]()
    
    var curNodeDefInvalid = false
    var curNodeDefIdent: String? = nil
    var curNodeDefInputs: [TypedIdent]? = nil
    var curNodeDefOutput: TypedIdent? = nil
    
    static let mtlxTypeToUSDAType: [String: String] = [
        "float": "float",
        "vector2": "float2",
        "float2": "float2", // ND_realitykit_image_gradient2d_* nodes use this type
        "vector3": "float3",
        "vector4": "float4",
        "half": "half",
        "half2": "half2",
        "half3": "half3",
        "half4": "half4",
        "integer": "int",
        "integer2": "int2",
        "integer3": "int3",
        "integer4": "int4",
        "color3": "color3f",
        "color4": "color4f",
        "matrix22": "matrix2d",
        "matrix33": "matrix3d",
        "matrix44": "matrix4d",
        "boolean": "bool",
        "string": "string",
        "filename": "asset",
        "texture2dfloat": "asset",
        "texture3dfloat": "asset",
        "texturecubefloat": "asset",
        "texture2dhalf": "asset",
        "texture3dhalf": "asset",
        "texturecubehalf": "asset",
        "surfaceshader": "token",
        "vertex": "token",
    ]
    
    func printVerbose(_ msg: String) {
        if self.verbose {
            print(msg)
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "nodedef", let name = attributeDict["name"], !name.contains("Internal") {
            curNodeDefInvalid = false
            curNodeDefIdent = name
            curNodeDefInputs = nil
            curNodeDefOutput = nil
        } else if let curNodeDefIdent = curNodeDefIdent, elementName == "input" {
            guard let name = attributeDict["name"],
                  let mtlxType = attributeDict["type"] else {
                printVerbose("Node def \(curNodeDefIdent) input missing expected attributes! Skipping")
                curNodeDefInvalid = true
                return
            }
            
            guard let usdaType = Self.mtlxTypeToUSDAType[mtlxType] else {
                printVerbose("Node def \(String(describing: curNodeDefIdent)) has unrecognized type when parsing MaterialX XML: \(mtlxType)! Skipping")
                curNodeDefInvalid = true
                return
            }
            
            curNodeDefInputs = (curNodeDefInputs ?? []) + [TypedIdent(ident: name, type: usdaType)]
        } else if let curNodeDefIdent = curNodeDefIdent, elementName == "output" {
            guard let name = attributeDict["name"],
                  let mtlxType = attributeDict["type"] else {
                printVerbose("Node def \(curNodeDefIdent) output missing expected attributes! Skipping")
                curNodeDefInvalid = true
                return
            }
            
            guard let usdaType = Self.mtlxTypeToUSDAType[mtlxType] else {
                printVerbose("Node def \(curNodeDefIdent) has unrecognized type when parsing MaterialX XML: \(mtlxType)! Skipping")
                curNodeDefInvalid = true
                return
            }
            
            if curNodeDefOutput != nil {
                printVerbose("Node def \(curNodeDefIdent) has multiple outputs! Not supported by language, skipping")
                curNodeDefInvalid = true
                return
            }
            
            let usdaName = curNodeDefIdent != "ND_realitykit_geometrymodifier_2_0_vertexshader" ? name : "vertex"
            curNodeDefOutput = TypedIdent(ident: usdaName, type: usdaType)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "nodedef" && !curNodeDefInvalid {
            if let curNodeDefIdent = curNodeDefIdent,
               let curNodeDefOutput = curNodeDefOutput {
                let curNodeDefInputs = curNodeDefInputs ?? []
                nodeDefs[curNodeDefIdent] = NodeDef(inputs: curNodeDefInputs, output: curNodeDefOutput)
            }
            
            curNodeDefIdent = nil
            curNodeDefInputs = nil
            curNodeDefOutput = nil
        }
    }
}

typealias CallID = UInt32

struct TypedIdent {
    let ident: String
    let type: String
}

struct TypedConnect {
    let connect: String
    let type: String
}

struct NodeDef {
    let inputs: [TypedIdent]
    let output: TypedIdent
}

public enum Constant {
    case bool(Bool)
    case int(Int)
    case float(Double)
    case half(Double)
    case string(String)
    case vec2i(Int, Int)
    case vec3i(Int, Int, Int)
    case vec4i(Int, Int, Int, Int)
    case vec2f(Double, Double)
    case vec3f(Double, Double, Double)
    case vec4f(Double, Double, Double, Double)
    case vec2h(Double, Double)
    case vec3h(Double, Double, Double)
    case vec4h(Double, Double, Double, Double)
    case color3f(Double, Double, Double)
    case color4f(Double, Double, Double, Double)
    case asset
}

public enum Arg {
    case expr(Expr)
    case pass
}

public enum Expr {
    case constant(Constant)
    case variable(String)
    case call(ident: String, args: [Arg])
    indirect case `func`(paramIdents: [String], stmts: [Stmt], return: Expr)
}

public enum Stmt {
    case uniform(ident: String, type: String, value: Constant)
    case def(idents: String, value: Expr)
    case out(geometryModifier: String, surfaceShader: String)
}

public struct ProgramPart {
    let stmts: [Stmt]
}

fileprivate struct Parser {
    enum ParseError: LocalizedError {
        case expectedToken(String, Substring)
        case expectedIdent(Substring)
        case expectedType(Substring)
        case expectedConstant(Substring)
        case expectedArg(Substring)
        case expectedExpr(Substring)
        case expectedStmt(Substring)
        
        private func firstStmt(_ source: Substring) -> Substring {
            return source.prefix{ !$0.isNewline && $0 != Character(";") }
        }
        
        public var errorDescription: String? {
            switch self {
            case let .expectedToken(token, rest):
                return NSLocalizedString("Expected token \"\(token)\". Parsing stopped here: \(firstStmt(rest))", comment: "")
            case let .expectedIdent(rest):
                return NSLocalizedString("Expected identifier. Parsing stopped here: \(firstStmt(rest))", comment: "")
            case let .expectedType(rest):
                return NSLocalizedString("Expected type. Parsing stopped here: \(firstStmt(rest))", comment: "")
            case let .expectedConstant(rest):
                return NSLocalizedString("Expected constant. Parsing stopped here: \(firstStmt(rest))", comment: "")
            case let .expectedArg(rest):
                return NSLocalizedString("Expected argument. Parsing stopped here: \(firstStmt(rest))", comment: "")
            case let .expectedExpr(rest):
                return NSLocalizedString("Expected expression. Parsing stopped here: \(firstStmt(rest))", comment: "")
            case let .expectedStmt(rest):
                return NSLocalizedString("Expected statement. Parsing stopped here: \(firstStmt(rest))", comment: "")
            }
        }
    }
    
    func parseToken(_ str: inout Substring, token: String) -> Bool {
        try? str.trimPrefix{ $0.isWhitespace }
        if str.hasPrefix(token) {
            str.trimPrefix(token)
            return true
        } else {
            return false
        }
    }
    
    func parseIdent(_ str: inout Substring) -> String? {
        let identRegex = /[_a-zA-Z][_a-zA-Z0-9]*/
        let tmp = str.trimmingPrefix{ $0.isWhitespace }
        if let match = tmp.prefixMatch(of: identRegex) {
            str = tmp[match.range.upperBound...]
            return String(tmp[match.range])
        } else {
            return nil
        }
    }
    
    func parseType(_ str: inout Substring) -> String? {
        try? str.trimPrefix{ $0.isWhitespace }
        guard let typeIdent = parseIdent(&str) else {
            return nil
        }
        
        for (_, usdaType) in NodeDefParserDelegate.mtlxTypeToUSDAType {
            if usdaType == typeIdent {
                return usdaType
            }
        }
        
        return nil
    }
    
    func parseBool(_ str: inout Substring) -> Bool? {
        try? str.trimPrefix{ $0.isWhitespace }
        if str.hasPrefix("true") {
            str.trimPrefix("true")
            return true
        } else if str.hasPrefix("false") {
            str.trimPrefix("false")
            return false
        } else {
            return nil
        }
    }
    
    func parseInt(_ str: inout Substring) -> Int? {
        let intRegex = /-?[0-9]+/
        let tmp = str.trimmingPrefix{ $0.isWhitespace }
        if let match = tmp.prefixMatch(of: intRegex) {
            str = tmp[match.range.upperBound...]
            return Int(tmp[match.range])
        } else {
            return nil
        }
    }
    
    func parseFloat(_ str: inout Substring) -> Double? {
        let floatRegex = /-?[0-9]+(.[0-9]*)?f/
        let tmp = str.trimmingPrefix{ $0.isWhitespace }
        if let match = tmp.prefixMatch(of: floatRegex) {
            str = tmp[match.range.upperBound...]
            return Double(tmp[match.range].dropLast())
        } else {
            return nil
        }
    }
    
    func parseHalf(_ str: inout Substring) -> Double? {
        let halfRegex = /-?[0-9]+(.[0-9]*)?h/
        let tmp = str.trimmingPrefix{ $0.isWhitespace }
        if let match = tmp.prefixMatch(of: halfRegex) {
            str = tmp[match.range.upperBound...]
            return Double(tmp[match.range].dropLast())
        } else {
            return nil
        }
    }
    
    func parseString(_ str: inout Substring) -> String? {
        let stringRegex = /\"[^\"]*\"/
        let tmp = str.trimmingPrefix{ $0.isWhitespace }
        if let match = tmp.prefixMatch(of: stringRegex) {
            str = tmp[match.range.upperBound...]
            return String(tmp[match.range].dropFirst().dropLast())
        } else {
            return nil
        }
    }
    
    private func vec2Parser<T>(_ parseElem: @escaping (inout Substring) throws -> T?) -> (inout Substring) throws -> (T, T)? {
        return { str in
            var tmp = str
            tmp = tmp.trimmingPrefix{ $0.isWhitespace }
            if !parseToken(&tmp, token: "(") {
                throw ParseError.expectedToken("(", tmp)
            }
            
            guard let v0 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ",") {
                throw ParseError.expectedToken(",", tmp)
            }
            
            guard let v1 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ")") {
                throw ParseError.expectedToken(")", tmp)
            }
            
            str = tmp
            return (v0, v1)
        }
    }
        
    private func vec3Parser<T>(_ parseElem: @escaping (inout Substring) throws -> T?, suffix: String = "") -> (inout Substring) throws -> (T, T, T)? {
        return { str in
            var tmp = str
            tmp = tmp.trimmingPrefix{ $0.isWhitespace }
            if !parseToken(&tmp, token: "(") {
                throw ParseError.expectedToken("(", tmp)
            }
            
            guard let v0 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ",") {
                throw ParseError.expectedToken(",", tmp)
            }
            
            guard let v1 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ",") {
                throw ParseError.expectedToken(",", tmp)
            }
            
            guard let v2 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ")") {
                throw ParseError.expectedToken(")", tmp)
            }
            
            if !parseToken(&tmp, token: suffix) {
                throw ParseError.expectedToken(suffix, tmp)
            }
            
            str = tmp
            return (v0, v1, v2)
        }
    }
        
    private func vec4Parser<T>(_ parseElem: @escaping (inout Substring) throws -> T?) -> (inout Substring) throws -> (T, T, T, T)? {
        return { str in
            var tmp = str
            tmp = tmp.trimmingPrefix{ $0.isWhitespace }
            if !parseToken(&tmp, token: "(") {
                throw ParseError.expectedToken("(", tmp)
            }
            
            guard let v0 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ",") {
                throw ParseError.expectedToken(",", tmp)
            }
            
            guard let v1 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ",") {
                throw ParseError.expectedToken(",", tmp)
            }
            
            guard let v2 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ",") {
                throw ParseError.expectedToken(",", tmp)
            }
            
            guard let v3 = try parseElem(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            if !parseToken(&tmp, token: ")") {
                throw ParseError.expectedToken(")", tmp)
            }
            
            str = tmp
            return (v0, v1, v2, v3)
        }
    }
    
    func parseConstant(_ str: inout Substring) throws -> Constant? {
        if let v = parseBool(&str) {
            return .bool(v)
        } else if let v = parseFloat(&str) {
            return .float(v)
        } else if let v = parseHalf(&str) {
            return .half(v)
        } else if let v = parseInt(&str) {
            return .int(v)
        } else if let v = parseString(&str) {
            return .string(v)
        } else if let (v0, v1) = try? vec2Parser(parseInt)(&str) {
            return .vec2i(v0, v1)
        } else if let (v0, v1, v2) = try? vec3Parser(parseInt)(&str) {
            return .vec3i(v0, v1, v2)
        } else if let (v0, v1, v2, v3) = try? vec4Parser(parseInt)(&str) {
            return .vec4i(v0, v1, v2, v3)
        } else if let (v0, v1) = try? vec2Parser(parseFloat)(&str) {
            return .vec2f(v0, v1)
        } else if let (v0, v1, v2) = try? vec3Parser(parseFloat)(&str) {
            return .vec3f(v0, v1, v2)
        } else if let (v0, v1, v2, v3) = try? vec4Parser(parseFloat)(&str) {
            return .vec4f(v0, v1, v2, v3)
        } else if let (v0, v1) = try? vec2Parser(parseHalf)(&str) {
            return .vec2h(v0, v1)
        } else if let (v0, v1, v2) = try? vec3Parser(parseHalf)(&str) {
            if parseToken(&str, token: "c") {
                return .color3f(v0, v1, v2)
            } else {
                return .vec3h(v0, v1, v2)
            }
        } else if let (v0, v1, v2, v3) = try? vec4Parser(parseHalf)(&str) {
            if parseToken(&str, token: "c") {
                return .color4f(v0, v1, v2, v3)
            } else {
                return .vec4h(v0, v1, v2, v3)
            }
        } else if parseToken(&str, token: "@") {
            return .asset
        } else {
            return nil
        }
    }
    
    func parseArg(_ str: inout Substring) throws -> Arg? {
        if let expr = try parseExpr(&str) {
            return .expr(expr)
        } else if parseToken(&str, token: "-") {
            return .pass
        } else {
            return nil
        }
    }
    
    func parseExpr(_ str: inout Substring) throws -> Expr? {
        var tmp = str
        if let constant = try parseConstant(&tmp) {
            str = tmp
            return .constant(constant)
        } else if let ident = parseIdent(&tmp) {
            if parseToken(&tmp, token: "(") {
                var args = [Arg]()
                
                if let arg = try parseArg(&tmp) {
                    args.append(arg)
                    
                    while parseToken(&tmp, token: ",") {
                        guard let arg = try parseArg(&tmp) else {
                            throw ParseError.expectedArg(tmp)
                        }
                        args.append(arg)
                    }
                }
                
                if !parseToken(&tmp, token: ")") {
                    throw ParseError.expectedToken(")", tmp)
                }
                
                str = tmp
                return .call(ident: ident, args: args)
            } else {
                str = tmp
                return .variable(ident)
            }
        } else if parseToken(&tmp, token: "{") {
            if !parseToken(&tmp, token: "(") {
                throw ParseError.expectedToken("(", tmp)
            }
            
            var paramIdents = [String]()
            
			if !parseToken(&tmp, token: ")") {
				repeat {
					guard let paramIdent = parseIdent(&tmp) else {
						throw ParseError.expectedIdent(tmp)
					}
					
					paramIdents.append(paramIdent)
				} while parseToken(&tmp, token: ",")
				
				if !parseToken(&tmp, token: ")") {
					throw ParseError.expectedToken(")", tmp)
				}
			}
            
            if !parseToken(&tmp, token: "in") {
                throw ParseError.expectedToken("in", tmp)
            }
            
            var stmts = [Stmt]()
            while let stmt = try? parseStmt(&tmp) {
                try tmp.trimPrefix{ $0.isNewline || $0 == ";" }
                stmts.append(stmt)
            }
            
            guard let `return` = try parseExpr(&tmp) else {
                throw ParseError.expectedExpr(tmp)
            }
            
            if !parseToken(&tmp, token: "}") {
                throw ParseError.expectedToken("}", tmp)
            }
            
            str = tmp
            return .func(paramIdents: paramIdents, stmts: stmts, return: `return`)
        } else {
            return nil
        }
    }
    
    func parseStmt(_ str: inout Substring) throws -> Stmt? {
        var tmp = str
        if parseToken(&tmp, token: "uniform") {
            guard let ident = parseIdent(&tmp) else {
                throw ParseError.expectedIdent(tmp)
            }
            
            if !parseToken(&tmp, token: ":") {
                throw ParseError.expectedToken(":", tmp)
            }
            
            guard let type = parseType(&tmp) else {
                throw ParseError.expectedType(tmp)
            }
            
            if !parseToken(&tmp, token: "=") {
                throw ParseError.expectedToken("=", tmp)
            }
            
            guard let value = try parseConstant(&tmp) else {
                throw ParseError.expectedConstant(tmp)
            }
            
            str = tmp
            return .uniform(ident: ident, type: type, value: value)
        } else if parseToken(&tmp, token: "let") {
            guard let ident = parseIdent(&tmp) else {
                throw ParseError.expectedIdent(tmp)
            }
            
            if !parseToken(&tmp, token: "=") {
                throw ParseError.expectedToken("=", tmp)
            }
            
            guard let value = try parseExpr(&tmp) else {
                throw ParseError.expectedExpr(tmp)
            }
            
            str = tmp
            return .def(idents: ident, value: value)
        } else if parseToken(&tmp, token: "(") {
            guard let gmIdent = parseIdent(&tmp) else {
                throw ParseError.expectedIdent(tmp)
            }
            
            if !parseToken(&tmp, token: ",") {
                throw ParseError.expectedToken(",", tmp)
            }
            
            guard let ssIdent = parseIdent(&tmp) else {
                throw ParseError.expectedIdent(tmp)
            }
            
            if !parseToken(&tmp, token: ")") {
                throw ParseError.expectedToken(")", tmp)
            }
            
            str = tmp
            return .out(geometryModifier: gmIdent, surfaceShader: ssIdent)
        } else {
            return nil
        }
    }
    
    func parse(source: String) throws-> [Stmt]? {
        var stmts = [Stmt]()
        var tmp = Substring(source)
        while !tmp.isEmpty {
            guard let stmt = try parseStmt(&tmp) else {
                throw ParseError.expectedStmt(tmp)
            }
            
			try tmp.trimPrefix{ $0.isWhitespace || $0 == ";" }
            stmts.append(stmt)
        }
        
        return stmts
    }
}

fileprivate struct Codegen {
    struct Context {
        let nodeDefs: [String: NodeDef]
        var funcs = [String: (paramIdents: [String], stmts: [Stmt], return: Expr)]()
        var environment = [String: TypedConnect]()
        var uniforms = [String: TypedConnect]()
        var nextCallID: CallID = 1
        
        mutating func incCallID() -> CallID {
            let res = nextCallID
            nextCallID += 1
            return res
        }
        
        func connectString(ident: String) -> TypedConnect? {
            if let variableConnect = environment[ident] {
                return variableConnect
            } else if let uniformConnect = uniforms[ident] {
                return uniformConnect
            } else {
                return nil
            }
        }
    }
    
    var ctx: Context
    
    enum CodegenError : LocalizedError {
        case unknownVariableIdentifier(String)
        case unknownNodeIdentitifer(String)
        case wrongArgumentType(String, String, String, String)
        case functionArgumentType
        case unknownOutIdent(String, String)
        case wrongOutType(String, String)
        case wrongUniformType(String, String, String)
        
        public var errorDescription: String? {
            switch self {
            case let .unknownVariableIdentifier(ident):
                return NSLocalizedString("Unknown variable identifier: \(ident)", comment: "")
            case let .unknownNodeIdentitifer(ident):
                return NSLocalizedString("Unknown node identifier: \(ident)", comment: "")
            case let .wrongArgumentType(inputIdent, nodeIdent, expectedType, foundType):
                return NSLocalizedString("Wrong argument type for parameter \(inputIdent) when calling \(nodeIdent): expected type \(expectedType) but found type \(foundType)", comment: "")
            case .functionArgumentType:
                return NSLocalizedString("Can't pass functions as arguments fo another function", comment: "")
            case let .unknownOutIdent(gmIdent, ssIdent):
                return NSLocalizedString("Unknown output identifiers: \(gmIdent), \(ssIdent)", comment: "")
            case let .wrongOutType(gmType, ssType):
                return NSLocalizedString("Wrong output types: found \(gmType), \(ssType)", comment: "")
            case let .wrongUniformType(ident, expectedType, foundType):
                return NSLocalizedString("Wrong uniform type for \(ident): found type \(foundType), expected type \(expectedType)", comment: "")
            }
        }
    }
    
    func codegenConstant(_ constant: Constant) -> (value: String, type: String) {
        switch constant {
        case let .bool(v):
            return (v ? "true" : "false", "bool")
        case let .int(v):
            return ("\(v)", "int")
        case let .float(v):
            return ("\(v)", "float")
        case let .half(v):
            return ("\(v)", "half")
        case let .string(v):
            return ("\"\(v)\"", "string")
        case let .vec2i(v0, v1):
            return ("(\(v0), \(v1))", "int2")
        case let .vec3i(v0, v1, v2):
            return ("(\(v0), \(v1), \(v2))", "int3")
        case let .vec4i(v0, v1, v2, v3):
            return ("(\(v0), \(v1), \(v2), \(v3))", "int4")
        case let .vec2f(v0, v1):
            return ("(\(v0), \(v1))", "float2")
        case let .vec3f(v0, v1, v2):
            return ("(\(v0), \(v1), \(v2))", "float3")
        case let .vec4f(v0, v1, v2, v3):
            return ("(\(v0), \(v1), \(v2), \(v3))", "float4")
        case let .vec2h(v0, v1):
            return ("(\(v0), \(v1))", "half2")
        case let .vec3h(v0, v1, v2):
            return ("(\(v0), \(v1), \(v2))", "half3")
        case let .vec4h(v0, v1, v2, v3):
            return ("(\(v0), \(v1), \(v2), \(v3))", "half4")
        case let .color3f(v0, v1, v2):
            return ("(\(v0), \(v1), \(v2))", "color3f")
        case let .color4f(v0, v1, v2, v3):
            return ("(\(v0), \(v1), \(v2), \(v3))", "color4f")
        case .asset:
            return ("@@", "asset")
        }
    }
    
    mutating func codegenArg(_ arg: Arg) throws -> (eval: String, connect: TypedConnect)? {
        switch(arg) {
        case let .expr(expr):
            return try codegenExpr(expr)
        case .pass:
            return nil
        }
    }
    
    mutating func codegenExpr(_ expr: Expr) throws -> (eval: String, connect: TypedConnect)? {
        switch expr {
        case let .constant(constant):
            let typedConstant = codegenConstant(constant)
            let typedConnect = TypedConnect(connect: " = \(typedConstant.value)", type: typedConstant.type)
            return (eval: "", connect: typedConnect)
        case let .variable(ident):
            guard let connectString = ctx.connectString(ident: ident) else {
                throw CodegenError.unknownVariableIdentifier(ident)
            }
            
            return (eval: "", connect: connectString)
        case let .call(ident, args):
            if let f = ctx.funcs[ident] {
                var argEvals = ""
                var lastEnvValues = [TypedConnect?]()
                for (paramIdent, arg) in zip(f.paramIdents, args) {
                    guard let (eval, typedConnect) = try codegenArg(arg) else {
                        continue
                    }
                    
                    argEvals += eval
                    lastEnvValues.append(ctx.environment[paramIdent])
                    ctx.environment[paramIdent] = typedConnect
                }
                
                let stmtEvals = try f.stmts.map{ try codegenStmt($0) }.joined(separator: "\n")
                
                guard let (returnEval, returnConnect) = try codegenExpr(f.return) else {
                    throw CodegenError.functionArgumentType
                }
                
                for (paramIdent, lastEnvValue) in zip(f.paramIdents, lastEnvValues) {
                    ctx.environment[paramIdent] = lastEnvValue
                }
                
                let eval = """
                \(argEvals)
                \(stmtEvals)
                \(returnEval)
                """
                
                return (eval: eval, connect: returnConnect)
            }
            
            guard let nodeDef = ctx.nodeDefs[ident] else {
                throw CodegenError.unknownNodeIdentitifer(ident)
            }
            
            var argEvals = ""
            var argInputs = ""
            for (arg, input) in zip(args, nodeDef.inputs) {
                guard let (eval, typedConnect) = try codegenArg(arg) else {
                    continue
                }
                
                if input.type != typedConnect.type {
                    throw CodegenError.wrongArgumentType(input.ident, ident, input.type, typedConnect.type)
                }
                
                argEvals += eval
                argInputs += """
                        \(input.type) inputs:\(input.ident)\(typedConnect.connect)\n
                """
            }
            
            let output = nodeDef.output
            let applyID = ctx.incCallID()
            let eval = """
            \(argEvals)
                def Shader "a\(applyID)"
                {
                    uniform token info:id = "\(ident)"
            \(argInputs)
                    \(output.type) outputs:\(output.ident)
                }
            """
            let connect = ".connect = </bm/a\(applyID).outputs:\(output.ident)>"
            let typedConnect = TypedConnect(connect: connect, type: output.type)
            return (eval: eval, connect: typedConnect)
        case .func:
            return nil
        }
    }
    
    mutating func codegenStmt(_ stmt: Stmt) throws -> String {
        switch stmt {
        case let .uniform(ident, type, value):
            let typedValue = codegenConstant(value)
            let connect = ".connect = </bm.inputs:\(ident)>"
            if type != typedValue.type {
                throw CodegenError.wrongUniformType(ident, type, typedValue.type)
            }
            
            ctx.uniforms[ident] = TypedConnect(connect: connect, type: type)
            return """
                \(type) inputs:\(ident) = \(typedValue.value) ()
            """
        case let .def(ident, value):
            if let (eval, connect) = try codegenExpr(value) {
                ctx.environment[ident] = connect
                return eval
            } else if case let .func(paramIdents, stmts, `return`) = value {
                ctx.funcs[ident] = (paramIdents: paramIdents, stmts: stmts, return: `return`)
            }
            
            return ""
        case let .out(geometryModifier, surfaceShader):
            guard let gmConnect = ctx.connectString(ident: geometryModifier),
                  let ssConnect = ctx.connectString(ident: surfaceShader) else {
                throw CodegenError.unknownOutIdent(geometryModifier, surfaceShader)
            }
            if gmConnect.type != "token", ssConnect.type != "token" {
                throw CodegenError.wrongOutType(gmConnect.type, ssConnect.type)
            }
            
            return """
                token outputs:realitykit:vertex\(gmConnect.connect)
                token outputs:mtlx:surface\(ssConnect.connect)
            """
        }
    }
    
    mutating func codegen(program: [Stmt]) throws -> String {
        let programUSDA = try program.map{
            try codegenStmt($0)
        }.filter{!$0.isEmpty}.joined(separator: "\n")
        
        return """
        #usda 1.0
        (
            defaultPrim = "bm"
            metersPerUnit = 1
            upAxis = "Y"
        )
        def Material "bm"
        {
        \(programUSDA)
        }
        """
    }
}

public struct Compiler {
    let nodeDefs: [String: NodeDef]
	let snippetCache: [Int: ProgramPart] = [:]
    
    public init?(mtlxNodeDefsFiles: [String]) {
        var nodeDefs = [String: NodeDef]()
        for mtlxNodeDefsFile in mtlxNodeDefsFiles {
            guard let mtlxNodeDefsData = mtlxNodeDefsFile.data(using: .utf8) else {
                print("Failed to create utf8 Data object from node def file")
                continue
            }
            
            let nodeDefParserDelegate = NodeDefParserDelegate()
            let nodeDefParser = XMLParser(data: mtlxNodeDefsData)
            nodeDefParser.delegate = nodeDefParserDelegate
            
            if !nodeDefParser.parse() {
                print("Failed to parse XML node def file: \(String(describing: nodeDefParser.parserError))")
                return nil
            }
            
            nodeDefs.merge(nodeDefParserDelegate.nodeDefs, uniquingKeysWith: { v0, v1 in v0 })
        }
        
        self.nodeDefs = nodeDefs
    }
    
	public mutating func parse(source: String, useCache: Bool = false) -> ProgramPart? {
		if (useCache) {
			let hash = source.hashValue
			if snippetCache[hash] != nil {
				return snippetCache[hash]
			}
		}
		
        do {
            let stmts = try Parser().parse(source: source)
            return stmts.map{ ProgramPart(stmts: $0) }
        } catch let error as LocalizedError {
            print("Error parsing source: \(error.localizedDescription)")
            return nil
        } catch {
            print("Unknown error hit when parsing: \(error)")
            return nil
        }
    }
    
    public func compile(parts: [ProgramPart]) -> String? {
        let context = Codegen.Context(nodeDefs: self.nodeDefs)
        var codegen = Codegen(ctx: context)
        do {
            let stmts = parts.flatMap{ $0.stmts }
            let usda = try codegen.codegen(program: stmts)
            return usda
        } catch let error as LocalizedError {
            print("Error compiling program: \(error.localizedDescription)")
            return nil
        } catch {
            print("Unknown error hit when compiling: \(error)")
            return nil
        }
    }
	
	public static func invalidProgram() -> String? {
		return nil
	}
}
