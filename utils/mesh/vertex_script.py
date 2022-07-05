import bpy

obj = bpy.context.selected_objects[0]

json = {
    'groups': []
}

for group in obj.vertex_groups:
    
    group_dict = {
        'group_name': group.name,
        'vertices': []
    }
    
    for vertex in obj.data.vertices:
        for g in vertex.groups:
            if g.group == group.index:
                vertex_dict = {
                    'x': vertex.co[0],
                    'y': vertex.co[1],
                    'z': vertex.co[2]
                }
                group_dict['vertices'].append(vertex_dict)
    
    json['groups'].append(group_dict)


import os
with open(os.path.splitext(bpy.data.filepath)[0] + '.json', 'w') as fs:
    json_str = str(json).replace("'", '"')
    fs.write(json_str)
