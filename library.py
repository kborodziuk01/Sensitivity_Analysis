import configparser
import glob
import os
import shutil

import matplotlib.pyplot as plt
import numpy
import pynetlogo
from scipy import stats


def load_config(path):

    config = configparser.ConfigParser()
    config.read(path)
    return config


def instance_netlogo(model,jvm,gui):
    netlogo = pynetlogo.NetLogoLink(
        gui=gui,
        jvm_path=jvm,
    )

    netlogo.load_model(model)

    return netlogo

def default_values(config):
    default = config["DEFAULT_VALUES"]
    l = {x:default[x] for x in default}

    return l


def target_variables_parse(config):

    test_variable_str = config["INPUT"]['TEST_VARIABLE']
    test_variable_list = test_variable_str.strip('[]').split(',')

    test_variable_list = [var.strip().lower() for var in test_variable_list]

    return test_variable_list



def setup_default_model(netlogo,default):
    for x in default:
        netlogo.command(f"set {x} {default[x]}")



def test_range_calc(param,default,range,split):
    perc = float(default[param]) * range
    mini = float(default[param]) - perc
    maxi = float(default[param]) + perc
    if float(default[param]) < 1.0 and maxi >1.0:
        maxi = 1.0
    if float(default[param]) < 1.0 and mini <0.0:
        maxi = 0.0
    diff = maxi - mini
    step = diff / split

    return [round(mini,5),round(maxi,5),round(step,5)]


def step_list_(mini,step,var_split):
    step_list = []
    m = mini
    for x in range(var_split+1):
        step_list.append(m)
        m += step
        m = round(m, 5)
    return step_list

def scaled(mini,maxi,step_list):
    scaled = []
    for x in step_list:
        scaled.append(round((x - mini) / (maxi - mini), 5))

    return scaled

def write_report(big_res,meta,OUT):

    for x in big_res:

        header = f"{x},Scaled Value,inf_a\n"
        if not os.path.exists(f"{OUT}/{x}"):
            os.makedirs(f"{OUT}/{x}")
        try:
            with open(f"{OUT}/{x}/report.csv", "w") as file:
                file.write(header)
                for z in range(len(big_res[x][1])):
                    file.write(f"{big_res[x][1][z]},{big_res[x][2][z]},{big_res[x][0][z]}\n")
        except:
            pass

    if not os.path.exists(f"{OUT}/meta"):
        os.makedirs(f"{OUT}/meta")

    header = f"Parameter,Slope,R_Squared\n"

    try:
        with open(f"{OUT}/meta/report.csv", "w") as file:
            file.write(header)
            for x in meta:
                file.write(f"{x[0]},{x[1]},{x[2]}\n")

    except:
        pass



def move_images(OUT):
    pics = glob.glob(f"{OUT}/pic/*.png")
    pic_names = [a.split("\\")[-1].split(".")[0] for a in pics]

    for pic in pics:
        name = pic.split("\\")[-1].split(".")[0]
        shutil.move(pic,f"{OUT}/{name}/")




################################################
def plot_data(param,pname,OUT):

    x = param[2]
    y = param[0]
    x_a = numpy.array(x)
    y_a = numpy.array(y)
    plt.style.use("ggplot")
    plt.ylim(200,1800)
    plt.scatter(x_a, y_a)
    sl, i, rv, pv, se = stats.linregress(x_a, y_a)
    plt.plot(x_a,sl*x_a+i)
    plt.ioff()
    if not os.path.exists(f"{OUT}/pic/"):
        os.makedirs(f"{OUT}/pic/")
    plt.savefig(f"{OUT}/pic/{pname}.png")
    plt.clf()
    return sl, rv**2

    # x_axis = [z[0] for z in rep]
    # y_sus_h = [z[1] for z in rep]
    # y_exp_h = [z[2] for z in rep]
    # y_inf_h = [z[3] for z in rep]
    # y_sus_a = [z[4] for z in rep]
    # y_exp_a = [z[5] for z in rep]
    # y_inf_a = [z[6] for z in rep]
    # y_d = [z[7] for z in rep]
    #
    # fig, axd = plt.subplot_mosaic([['left', 'right']], layout='constrained')
    # axd['left'].set_facecolor('gray')
    # axd['left'].set_title(title)
    # axd['left'].plot(x_axis,y_sus_h,color = "green",label="Susceptible Humans",linestyle='-')
    # axd['left'].plot(x_axis,y_exp_h,color='blue',label="Exposed Humans",linestyle='--')
    # axd['left'].plot(x_axis,y_inf_h,color="red",label="Infected Humans",linestyle='-.')
    # axd['left'].plot(x_axis,y_d,color="yellow",label="Dairy Products",linestyle=':')
    # axd['left'].grid(True)
    # axd['left'].legend()
    #
    # axd['right'].set_facecolor('gray')
    # axd['right'].set_title(title2)
    # axd['right'].plot(x_axis,y_sus_a,color = "green",label="Susceptible Animals",linestyle='-')
    # axd['right'].plot(x_axis,y_exp_a,color='blue',label="Exposed Animals",linestyle='--')
    # axd['right'].plot(x_axis,y_inf_a,color="red",label="Infected Animals",linestyle='-.')
    # axd['right'].plot(x_axis,y_d,color="yellow",label="Dairy Products",linestyle=':')
    # axd['right'].grid(True)
    # axd['right'].legend()





    # Plot some data on the axes.