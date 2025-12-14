import os
import numpy as np
import pandas as pd
import NewareNDA

def clip_data(df, step_lists, gap = 0.001):
    dat_list = []
    for step_list in step_lists:
        dat = df[df["Step"].isin(step_list)]
        dat = dat.reset_index(drop=True)
        time_backshift = 0
        for i in dat.index[1:]:
            if dat["Step"][i] != dat["Step"][i - 1]:
                dat.loc[i:,"Time"] = dat["Time"][i:] + dat["Time"][i - 1] - time_backshift
                time_backshift = dat["Time"][i-1]
                dat.loc[i,"Time"] = dat["Time"][i] + gap

        dat_list = dat_list + [dat]
    return  dat_list
########################################################################################################################

input_folder = r'.\П1-047'  # Папка где лежат все эксперименты
input_base_name = '101-1-3-П1-047' # имя основного (первого) файла результатов, без расширения (.ndax)
input_filepath = os.path.join(input_folder, input_base_name+'.ndax')
output_folder = os.path.join(input_folder, input_base_name+'_processed')
gap = 0.001
###################################################################
### пример создания windows для программый с циклом
cycle_size = 3 # кол-во шагов в цикле
N_cyc = 36 # кол-во циклов (повторов)
cycle_start = 3 # номер шага, на котором начинается цикл
cyc = np.arange(0, cycle_size, 1)
step_lists = [[1, 2]] # первичные шаги, не входящие в цикл
for i in range(0,N_cyc):
    step_lists = step_lists + [(cycle_start + i*cycle_size + cyc).tolist()]


###################################################################
df = NewareNDA.read(input_filepath)
df = df[["Step", "Time","Current(mA)","Voltage","T1"]]
df = df.rename(columns={"Current(mA)": "I", "Voltage": "E", "T1":"T"})
df["I"] = df["I"]/1000

dat_list = clip_data(df, step_lists, gap = 0.001)
if not os.path.exists(output_folder):
    os.makedirs(output_folder)
for k, dat in enumerate(dat_list):
    output_filepath = os.path.join(output_folder, f'{k:03d}.csv')
    dat.to_csv(output_filepath, index=False, sep ='\t')
print('fin')

