@tool
extends ValveIONode

@onready var mi = $MeshInstance3D;
@onready var de = $Decal;

func _apply_entity(e):
	super._apply_entity(e);

	var isDecalMode = not "geometry" in e;

	VTFTool.importMaterial(e.material);
	var material = VTFTool.getMaterial(e.material) if not isDecalMode else load("res://Assets/Materials/" + e.material + ".png");

	if not material:
		queue_free();
		return;

	var mesh = ArrayMesh.new();

	var uvs = [
		Vector2(e.StartU, e.StartV),
		Vector2(e.StartU, e.EndV),
		Vector2(e.EndU, e.EndV),
		Vector2(e.EndU, e.StartV),
	];

	var verts = [
		convert_vector(e.uv0) * config.import.scale,
		convert_vector(e.uv1) * config.import.scale,
		convert_vector(e.uv2) * config.import.scale,
		convert_vector(e.uv3) * config.import.scale,
	];

	var st = SurfaceTool.new();
	var normal = convert_vector(e.BasisNormal);

	st.begin(Mesh.PRIMITIVE_TRIANGLES);
	st.set_normal(normal);

	var index = 0;
	for vert in verts:
		st.set_uv(uvs[index]);
		st.add_vertex(vert);
		index += 1;

	var indices = [0, 1, 2, 0, 2, 3];
	for i in indices:
		st.add_index(i);

	st.generate_normals();
	st.generate_tangents();
	st.set_material(material);
	st.commit(mesh);
		
	var aabb = mesh.get_aabb().size;

	if isDecalMode:
		de.size.x = aabb.x;
		de.size.z = aabb.z;

		var s = -1 if normal.dot(Vector3.BACK) > 0 or normal.dot(Vector3.RIGHT) > 0 or normal.dot(Vector3.UP) > 0 else 1;

		var normalmap = load("res://Assets/Materials/" + e.material + "_norm.jpg");

		de.texture_albedo = material;
		de.texture_normal = normalmap;
		de.basis.x = -convert_vector(e.BasisU) * s;
		de.basis.z = convert_vector(e.BasisV) * s;
		de.basis.y = normal;
		mi.queue_free();
	else:
		de.queue_free();
		mi.set_mesh(mesh);
		mi.position += normal * 0.001;
		mi.basis.x = convert_vector(e.BasisU);
		mi.basis.z = -convert_vector(e.BasisV);
		mi.basis.y = normal;
