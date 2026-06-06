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

#include "mesh_loader.h"
#include "bridge.h"
#include "signposts.h"
#include "utility.h"

#include <godot_cpp/templates/sort_array.hpp>

using namespace gdrk;

namespace {

// Each RS getter (get_format_vertex_stride, get_format_offset, etc.) independently calls
// mesh_surface_make_offsets_from_format, which loops over all ARRAY_MAX (13) slots to compute
// strides and offsets in one pass, then discards all but the one value the caller asked for.
// A single-pass equivalent isn't exposed through the GDExtension boundary, so filling a full
// GDRKVertexBufferFormat costs 10 redundant passes through that loop (9 get_format_offset calls
// + the stride calls). This is called twice per surface change (once for compressed, once for
// decompressed format) — acceptable since it only runs on the cold mesh-change path, never
// per-frame.
static GDRKVertexBufferFormat format_to_gdrk(godot::RenderingServer *rs, uint64_t format, uint32_t vertex_count) {
	const bool has_deform = (format & godot::RenderingServer::ARRAY_FORMAT_BONES) != 0 &&
			(format & godot::RenderingServer::ARRAY_FORMAT_WEIGHTS) != 0;
	const uint32_t skin_stride = has_deform
			? rs->mesh_surface_get_format_skin_stride(format, vertex_count) / uint32_t(sizeof(uint32_t))
			: 0u;
	return GDRKVertexBufferFormat{
		.vertex_stride = rs->mesh_surface_get_format_vertex_stride(format, vertex_count),
		.normal_tangent_stride = rs->mesh_surface_get_format_normal_tangent_stride(format, vertex_count),
		.attribute_stride = rs->mesh_surface_get_format_attribute_stride(format, vertex_count),
		.vertex_offset = rs->mesh_surface_get_format_offset(format, vertex_count, godot::RenderingServer::ARRAY_VERTEX),
		.normal_offset = rs->mesh_surface_get_format_offset(format, vertex_count, godot::RenderingServer::ARRAY_NORMAL),
		.tangent_offset = rs->mesh_surface_get_format_offset(format, vertex_count, godot::RenderingServer::ARRAY_TANGENT),
		.color_offset = rs->mesh_surface_get_format_offset(format, vertex_count, godot::RenderingServer::ARRAY_COLOR),
		.uv1_offset = rs->mesh_surface_get_format_offset(format, vertex_count, godot::RenderingServer::ARRAY_TEX_UV),
		.uv2_offset = rs->mesh_surface_get_format_offset(format, vertex_count, godot::RenderingServer::ARRAY_TEX_UV2),
		.skin_stride = skin_stride,
		.skin_weight_offset = skin_stride / 2,
	};
}

} //namespace

static uint8_t get_vertex_buffer_flags(uint64_t format, bool compressed_uvs) {
	using RS = godot::RenderingServer;

	WARN_COMPAT_COND((format & (uint64_t(RS::ARRAY_FLAG_FORMAT_VERSION_MASK) << RS::ARRAY_FLAG_FORMAT_VERSION_SHIFT)) !=
			RS::ARRAY_FLAG_FORMAT_CURRENT_VERSION);

	uint8_t flags = 0;
	if (format & godot::RenderingServer::ARRAY_FORMAT_NORMAL) {
		flags |= GodotRealityKit::VertexBufferFlags::getHasNormals().getRawValue();
	}

	if (format & godot::RenderingServer::ARRAY_FORMAT_TANGENT) {
		flags |= GodotRealityKit::VertexBufferFlags::getHasTangents().getRawValue();
	}

	if (format & godot::RenderingServer::ARRAY_FORMAT_COLOR) {
		flags |= GodotRealityKit::VertexBufferFlags::getHasColor().getRawValue();
	}

	if (format & godot::RenderingServer::ARRAY_FORMAT_TEX_UV) {
		flags |= GodotRealityKit::VertexBufferFlags::getHasUV1().getRawValue();
	}

	if (format & godot::RenderingServer::ARRAY_FORMAT_TEX_UV2) {
		flags |= GodotRealityKit::VertexBufferFlags::getHasUV2().getRawValue();
	}

	if (format & godot::RenderingServer::ARRAY_FLAG_COMPRESS_ATTRIBUTES) {
		flags |= GodotRealityKit::VertexBufferFlags::getHasCompressedAttributes().getRawValue();
	}

	if (compressed_uvs) {
		flags |= GodotRealityKit::VertexBufferFlags::getHasCompressedUVs().getRawValue();
	}

	return flags;
}

void MeshLoader::initialize() {
	mesh_encoder.initialize();
}

uint32_t MeshLoader::find_or_add(godot::RID p_mesh_rid,
		uint64_t p_instance_id,
		godot::Mesh *p_mesh,
		godot::Skeleton3D *p_skeleton) {
	const MeshKey key = MeshKey{
		.mesh_rid = p_mesh_rid,
		.instance_id = p_instance_id,
	};

	const auto found = mesh_to_idx.find(key);
	if (found) {
		return found->value;
	}

	const uint32_t idx = alloc_idx();

	const uint32_t mesh_rid_idx = p_mesh_rid.get_id() & 0xFFFFFFFF;
	if (mesh_rid_idx >= dirty_mesh_rid_idxs.size()) {
		dirty_mesh_rid_idxs.resize(mesh_rid_idx + 1);
	}

	if (p_mesh) {
		godot::Callable mesh_changed_callable =
				callable_mp(this, &MeshLoader::mesh_changed).bind(mesh_rid_idx);
		if (!p_mesh->is_connected("changed", mesh_changed_callable)) {
			p_mesh->connect("changed", mesh_changed_callable);
		}
	}

	uint64_t skeleton_id = 0;
	if (p_skeleton) {
		skeleton_id = p_skeleton->get_instance_id();
		godot::Callable pose_updated_callable =
				callable_mp(this, &MeshLoader::skeleton_pose_updated).bind(skeleton_id);
		if (!p_skeleton->is_connected("pose_updated", pose_updated_callable)) {
			p_skeleton->connect("pose_updated", pose_updated_callable);
		}
	}

	meshes[idx] = Mesh{
		.mesh_rid = p_mesh_rid,
		.instance_id = p_instance_id,
	};

	mesh_rid_idxs[idx] = mesh_rid_idx;
	meshes[idx].skeleton_id = skeleton_id;
	mesh_to_idx.insert(key, idx);

	return idx;
}

void MeshLoader::remove(uint32_t p_idx) {
	mesh_to_idx.erase(MeshKey{
			.mesh_rid = meshes[p_idx].mesh_rid,
			.instance_id = meshes[p_idx].instance_id,
	});

	meshes[p_idx] = Mesh();
	mesh_rid_idxs[p_idx] = UINT32_MAX;
	meshes[p_idx].skeleton_id = 0;
	free_idx(p_idx);
}

void MeshLoader::add_instance(uint32_t p_idx, godot::RID p_instance_rid) {
	meshes[p_idx].instance_rids.push_back(p_instance_rid);
}

void MeshLoader::remove_instance(uint32_t p_idx, godot::RID p_instance_rid) {
	meshes[p_idx].instance_rids.erase(p_instance_rid);
}

void MeshLoader::add_skeleton_modifier(godot::SkeletonModifier3D *p_skeleton_modifier) {
	godot::Skeleton3D *skeleton = p_skeleton_modifier->get_skeleton();
	if (!skeleton) {
		return;
	}
	const uint64_t skeleton_id = skeleton->get_instance_id();
	godot::Callable pose_updated_callable =
			callable_mp(this, &MeshLoader::skeleton_pose_updated).bind(skeleton_id);
	if (!p_skeleton_modifier->is_connected("modification_processed", pose_updated_callable)) {
		p_skeleton_modifier->connect("modification_processed", pose_updated_callable);
	}
}

void MeshLoader::skeleton_pose_updated(uint64_t p_skeleton_id) {
	dirty_skeleton_ids.insert(p_skeleton_id);

	godot::Object *obj = godot::ObjectDB::get_instance(p_skeleton_id);
	godot::Skeleton3D *skeleton = godot::Object::cast_to<godot::Skeleton3D>(obj);
	if (!skeleton) {
		return;
	}
	const int32_t bone_count = skeleton->get_bone_count();

	// Snapshot bone poses now — before Skeleton3D restores pre-modifier state.
	for (uint32_t idx = 0; idx < get_capacity(); idx++) {
		if (!is_valid(idx) || meshes[idx].skeleton_id != p_skeleton_id) {
			continue;
		}
		godot::LocalVector<godot::Transform3D> &snapshot = meshes[idx].bone_pose_snapshot;
		snapshot.resize(bone_count);
		for (int32_t i = 0; i < bone_count; i++) {
			snapshot[i] = skeleton->get_bone_global_pose(i);
		}
	}
}

void MeshLoader::set_blend_shape_weights(uint32_t p_idx, Span<const float> p_weights) {
	Mesh &mesh = meshes[p_idx];
	mesh.blend_shape_weights = SmallLocalVector<float, 8>(p_weights);
	mesh_dirty_position_idxs.insert(p_idx);
}

void MeshLoader::set_skin(uint32_t p_idx, const godot::Ref<godot::Skin> &p_skin) {
	Mesh &mesh = meshes[p_idx];
	if (mesh.skin == p_skin) {
		return;
	}
	mesh.skin = p_skin;
	mesh_dirty_position_idxs.insert(p_idx);
}

bool MeshLoader::update(id<MTLCommandBuffer> p_command_buffer) {
	PROFILE_FUNC_SCOPE;

	if (dirty_mesh_rid_idxs.count() > 0) {
		for (uint32_t idx = 0; idx < get_capacity(); idx++) {
			const uint32_t mesh_rid_idx = mesh_rid_idxs[idx];
			if (is_valid(idx) && dirty_mesh_rid_idxs.has(mesh_rid_idx)) {
				dirty_idxs.insert(idx);
			}
		}
	}

	mesh_encoder.start(p_command_buffer);

	bool finished = for_each_dirty_throttled([&](uint32_t idx) {
		const godot::RID mesh_rid = meshes[idx].mesh_rid;

		godot::RenderingServer *rs = rendering_server();
		const uint32_t surface_count = rs->mesh_get_surface_count(mesh_rid);
		SmallLocalVector<godot::Dictionary, 8> surface_dicts;
		SmallLocalVector<Mesh::SurfaceInfo, 8> surface_infos;
		surface_dicts.reserve(surface_count);
		surface_infos.reserve(surface_count);

		for (uint32_t surface_idx = 0; surface_idx < surface_count; surface_idx++) {
			surface_dicts.push_back(rs->mesh_get_surface(mesh_rid, surface_idx));
			surface_infos.push_back(get_surface_info(surface_dicts[surface_idx], mesh_rid));
		}

		meshes[idx].blend_shape_count = mesh_rid.is_valid() ? uint32_t(rs->mesh_get_blend_shape_count(mesh_rid)) : 0u;
		meshes[idx].normalized_blend_shapes =
				rs->mesh_get_blend_shape_mode(mesh_rid) == godot::RenderingServer::BLEND_SHAPE_MODE_NORMALIZED;

		bool surfaces_need_new_resources = false;
		if (meshes[idx].surface_infos.size() == surface_infos.size()) {
			for (uint32_t surface_idx = 0; surface_idx < surface_count; surface_idx++) {
				if (surface_needs_new_resource(surface_infos[surface_idx], meshes[idx].surface_infos[surface_idx])) {
					surfaces_need_new_resources = true;
					break;
				}
			}
		} else {
			surfaces_need_new_resources = true;
		}

		if (surfaces_need_new_resources) {
			meshes[idx].surfaces.reset();
			meshes[idx].surfaces.reserve(surface_count);

			for (uint32_t surface_idx = 0; surface_idx < surface_count; surface_idx++) {
				const Mesh::SurfaceInfo &info = surface_infos[surface_idx];
				const bool is_index_16 = info.vertex_count <= 65536 && info.vertex_count > 0;
				const bool is_compressed = surface_has_compressed_attributes(info.vertex_buffer_flags);
				const GDRKVertexBufferFormat llm_format = is_compressed
						? info.decompressed_vertex_buffer_format
						: info.vertex_buffer_format;
				const uint8_t llm_flags = is_compressed
						? compute_decompressed_flags(info.vertex_buffer_flags)
						: info.vertex_buffer_flags;
				swift::Optional<GodotRealityKit::LowLevelMesh> low_level_mesh =
						GodotRealityKit::LowLevelMesh::init(info.vertex_count,
								info.index_count,
								GodotRealityKit::VertexBufferFlags::init(llm_flags),
								llm_format,
								is_index_16,
								1);

				ERR_FAIL_COND_MSG(low_level_mesh.isNone(), "Failed to create low level mesh");

				low_level_mesh.get().setIndexCount(info.index_count);

				swift::Optional<GodotRealityKit::MeshResource> mesh_resource =
						GodotRealityKit::MeshResource::init(low_level_mesh.get(), to_vector3(info.bounds.position),
								to_vector3(info.bounds.position + info.bounds.size), to_vector4(info.uv_scale));
				ERR_FAIL_COND(mesh_resource.isNone());

				meshes[idx].surfaces.push_back(Mesh::Surface{ .resource = mesh_resource.get() });
			}
			meshes[idx].instance_aabb = godot::AABB();
		} else {
			mesh_dirty_position_idxs.remove(idx);
		}

		// Store raw surface data and set encoding mode — encoder handles the rest.
		for (uint32_t surface_idx = 0; surface_idx < surface_count; surface_idx++) {
			const Mesh::SurfaceInfo &info = surface_infos[surface_idx];
			Mesh::Surface &surface = meshes[idx].surfaces[surface_idx];
			const bool is_compressed = surface_has_compressed_attributes(info.vertex_buffer_flags);

			surface.surface_data = surface_dicts[surface_idx];
			surface.base_vertex_mtl = nil;
			surface.skin_mtl = nil;
			surface.blend_shape_mtl = nil;

			surface.resource.setBounds(to_vector3(info.bounds.position), to_vector3(info.bounds.position + info.bounds.size));
			surface.resource.setUVScale(to_vector4(info.uv_scale));

			swift::Optional<GodotRealityKit::LowLevelMesh> low_level_mesh = surface.resource.lowLevelMesh();
			ERR_CONTINUE(low_level_mesh.isNone());
			low_level_mesh.get().setIndexCount(info.index_count);

			static godot::StringName skin_data_str("skin_data");
			static godot::StringName blend_shape_data_str("blend_shape_data");
			const bool has_deform_data = surface.surface_data.has(skin_data_str) ||
					surface.surface_data.has(blend_shape_data_str);
			const bool has_attributes =
					(info.vertex_buffer_flags & GodotRealityKit::VertexBufferFlags::getHasColor().getRawValue()) ||
					(info.vertex_buffer_flags & GodotRealityKit::VertexBufferFlags::getHasUV1().getRawValue()) ||
					(info.vertex_buffer_flags & GodotRealityKit::VertexBufferFlags::getHasUV2().getRawValue());
			surface.encoding_mode = MeshEncoder::EncodingMode(
					(has_deform_data ? MeshEncoder::ENCODING_MODE_FLAG_DEFORM : 0) |
					(is_compressed ? MeshEncoder::ENCODING_MODE_FLAG_COMPRESSED : 0) |
					(has_attributes ? MeshEncoder::ENCODING_MODE_FLAG_WITH_UV : 0));
		}

		meshes[idx].surface_infos = std::move(surface_infos);
		mesh_encoder.prepare(meshes[idx]);
		mesh_dirty_position_idxs.insert(idx);
	});

	if (dirty_skeleton_ids.size() > 0) {
		for (uint32_t idx = 0; idx < get_capacity(); idx++) {
			const uint64_t skeleton_id = meshes[idx].skeleton_id;
			if (is_valid(idx) && dirty_skeleton_ids.has(skeleton_id)) {
				mesh_dirty_position_idxs.insert(idx);
			}
		}
	}

	mesh_dirty_position_idxs.for_each([&](uint32_t idx) {
		if (idx >= next_dirty_idx) {
			return;
		}

		mesh_dirty_position_idxs.remove(idx);

		ERR_FAIL_COND(meshes[idx].instance_rids.is_empty());
		if (meshes[idx].surfaces.is_empty()) {
			return;
		}

		Mesh &mesh = meshes[idx];

		// Compute mesh-local AABB from per-surface bounds.
		godot::AABB instance_aabb;
		const uint32_t surface_count = mesh.surface_infos.size();
		if (surface_count > 0) {
			instance_aabb = mesh.surface_infos[0].bounds;
			for (uint32_t surface_idx = 1; surface_idx < surface_count; surface_idx++) {
				instance_aabb.merge_with(mesh.surface_infos[surface_idx].bounds);
			}
		}

		const bool bounds_dirty = bounds_changed(mesh.instance_aabb, instance_aabb, 0.1);
		if (bounds_dirty) {
			mesh.instance_aabb = instance_aabb;
			for (Mesh::Surface &surface : mesh.surfaces) {
				swift::Optional<GodotRealityKit::LowLevelMesh> llm = surface.resource.lowLevelMesh();
				if (llm.isSome()) {
					llm.get().setBounds(to_vector3(instance_aabb.position), to_vector3(instance_aabb.position + instance_aabb.size));
				}
			}
		}

		mesh_encoder.encode(mesh);
	});

	mesh_encoder.commit();

	dirty_mesh_rid_idxs.clear();
	dirty_skeleton_ids.clear();

	return finished;
}

swift::Optional<GodotRealityKit::MeshResource> MeshLoader::find_resource(godot::RID p_mesh_rid,
		uint64_t p_instance_id,
		uint32_t p_surface_idx) const {
	const Mesh *mesh = find_mesh(p_mesh_rid, p_instance_id, p_surface_idx);
	if (!mesh) {
		return swift::Optional<GodotRealityKit::MeshResource>::none();
	}

	return swift::Optional<GodotRealityKit::MeshResource>::some(mesh->surfaces[p_surface_idx].resource);
}

Mesh::SurfaceInfo MeshLoader::get_surface_info(const godot::Dictionary &surface, godot::RID p_mesh_rid) const {
	godot::RenderingServer *rs = godot::RenderingServer::get_singleton();
	const godot::RenderingServer::PrimitiveType primitive = godot::RenderingServer::PrimitiveType(int(surface["primitive"]));

	static godot::StringName uv_scale_str("uv_scale");
	static godot::StringName vertex_count_str("vertex_count");
	static godot::StringName index_count_str("index_count");
	static godot::StringName format_str("format");
	static godot::StringName aabb_str("aabb");

	const godot::Vector4 uv_scale = surface[uv_scale_str];
	const int32_t vertex_count = surface[vertex_count_str];
	const int32_t index_count = surface.get(index_count_str, vertex_count);
	const uint64_t format = surface[format_str];
	const godot::AABB aabb = surface[aabb_str];

	if (primitive != godot::RenderingServer::PRIMITIVE_TRIANGLES) {
		WARN_PRINT("Unhandled primitive type! Mesh may not show properly");
	}

	const uint64_t decompressed_format = format & ~(uint64_t)godot::RenderingServer::ARRAY_FLAG_COMPRESS_ATTRIBUTES;

	const GDRKVertexBufferFormat decompressed = format_to_gdrk(rs, decompressed_format, vertex_count);
	return Mesh::SurfaceInfo{
		.vertex_count = uint32_t(vertex_count),
		.index_count = uint32_t(index_count != 0 ? index_count : vertex_count),
		.vertex_buffer_flags = get_vertex_buffer_flags(format, uv_scale != godot::Vector4(0, 0, 0, 0)),
		.vertex_buffer_format = (format == decompressed_format) ? decompressed : format_to_gdrk(rs, format, vertex_count),
		.decompressed_vertex_buffer_format = decompressed,
		.bounds = aabb,
		.uv_scale = uv_scale,
	};
}

bool MeshLoader::surface_needs_new_resource(const Mesh::SurfaceInfo &p_cur, const Mesh::SurfaceInfo &p_new) const {
	return p_cur.vertex_count > p_new.vertex_count || p_cur.index_count > p_new.index_count ||
			p_cur.vertex_buffer_flags != p_new.vertex_buffer_flags;
}

bool MeshLoader::bounds_changed(const godot::AABB &p_cur, const godot::AABB &p_new, float p_percent) const {
	if (!p_cur.has_volume()) {
		return true;
	}

	const godot::Vector3 threshold = p_percent * p_cur.size;
	const godot::Vector3 pos_diff = (p_cur.position - p_new.position).abs();
	const godot::Vector3 size_diff = (p_cur.size - p_new.size).abs();

	return pos_diff.x > threshold.x || pos_diff.y > threshold.y || pos_diff.z > threshold.z ||
			size_diff.x > threshold.x || size_diff.y > threshold.y || size_diff.z > threshold.z;
}
