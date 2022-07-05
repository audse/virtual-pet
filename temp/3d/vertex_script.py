import bpy

groupName = "Group"

filename = "myVerts"


if (filename not in bpy.data.texts):
    myVerts = bpy.data.texts.new(filename)
else :
    myVerts = bpy.data.texts[filename]
    myVerts.clear()

myGroupsArr = [];

obj = bpy.context.selected_objects[0]

group = obj.vertex_groups[groupName]

for v in obj.data.vertices:
    for g in v.groups:
        print(g.group, group.index)
        if g.group == group.index:
            myGroupsArr.append()


for grp in myGroupsArr:
    myVerts.write( str(grp[0])+str(grp[1])+str(grp[2])+ "\n")