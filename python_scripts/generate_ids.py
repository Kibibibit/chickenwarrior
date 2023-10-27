import os

WEAPON_FOLDER_PATH = "../resources/items/weapons/"
WEAPON_ID_PATH = "../src/scripts/autoloads/weapon_id.gd"

PREFIX_WEAPON = "weapon_"
KEY_ITEM_ID = "item_id"


WEAPON_CONSTANTS = {
    "weapon_unarmed": "UNARMED"
}


def extract_id(file_path: str, key: str) -> str:
    with open(file_path, 'r') as file:
        for line in file.readlines():
            if (line.startswith(key)):
                output = line.removeprefix(key).replace("=","").replace('"',"").replace("&","").strip()
                file.close()
                return output

def create_var_name(file_id: str, prefix: str) -> str:
    output = file_id.removeprefix(prefix)
    return output.upper()


def create_ids_file(folder: str, output_file: str, constants: dict, key: str, prefix: str) -> None:
    
    filenames: list[str] = os.listdir(folder)

    ids = {}

    for constant_id in constants.keys():
        ids[constant_id] = constants[constant_id]

    for filename in filenames:
        path = "{}{}".format(folder, filename)
        if (os.path.isfile(path)):
            file_id = extract_id(path, key)
            constant_name = create_var_name(file_id, prefix)
            ids[file_id] = constant_name
    
    with open(output_file, 'w') as file:
        lines = [
            "extends Node\n",
            "\n",
            "\n"
        ]



        for file_id in ids.keys():
            constant_name = ids[file_id]

            lines.append('const {}: StringName = "{}"\n'.format(constant_name, file_id))
        
        lines.append("\n")
        lines.append("\n")
        lines.append("const ALL: Array[StringName] = [\n")
        
        for constant_name in ids.values():
            lines.append("\t{},\n".format(constant_name))

        lines.append("]")
        
        file.writelines(lines)
    
    file.close()



            



create_ids_file(WEAPON_FOLDER_PATH, WEAPON_ID_PATH, WEAPON_CONSTANTS, KEY_ITEM_ID, PREFIX_WEAPON)

