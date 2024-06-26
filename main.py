import library as lib
import os
import numpy

config = lib.load_config("./config.ini")

MODEL_PATH = config['PATHS']['MODEL_PATH']
JVM_PATH =  config["PATHS"]["JVM_PATH"]
OUT = config["PATHS"]["OUTPUT"]

test_range = float(config["PROCESS"]["RANGE"])
var_split = int(config["PROCESS"]["SPLIT"])
target = config["INPUT"]["TARGET"]
rep = int(config['PROCESS']['REPETITIONS'])

if not os.path.exists(OUT):
    os.makedirs(OUT)

if os.path.isfile(MODEL_PATH):
    netlogo = lib.instance_netlogo(MODEL_PATH,JVM_PATH,False)
else:
    raise Exception("Specified model path does not exist.")

default = lib.default_values(config)
test_var = lib.target_variables_parse(config)
lib.setup_default_model(netlogo,default)

big_res = {}
meta_res = {}

for var in test_var:
    print(f"Variable tested: {var}")
    mini,maxi,step = lib.test_range_calc(var,default,test_range,var_split)

    step_list = lib.step_list_(mini, step,var_split)
    scaled_param = lib.scaled(mini,maxi,step_list)

    param_result_list = []
    for x in range(var_split+1):
        #print(f"Test value {mini}")
        netlogo.command(f"set {var} {mini}")
        local_res = []
        for z in range(rep):

            netlogo.command("setup")
            netlogo.command("repeat 30 [go]")
            local_res.append(netlogo.report(target))
            #print(f"Repetition {z + 1}: {netlogo.report(target)}")

        param_result_list.append(sum(local_res)/len(local_res))
        #print(f"Average value: {sum(local_res)/len(local_res)}")
        mini += step
        mini = round(mini,5)



    big_res[var] = [param_result_list,step_list,scaled_param]
    slope,r2 = lib.plot_data(big_res[var],var,OUT)
    print(f"{var} slope: {slope}, r2: {r2}")
    meta_res[var] = [slope,r2]

    lib.setup_default_model(netlogo, default)


lib.move_images(OUT)
meta = [[x, meta_res[x][0], meta_res[x][1]] for x in meta_res.keys()]
lib.write_report(big_res,meta,OUT)
