#!/usr/bin/env python
# coding: utf-8

import pwlf
import numpy as np
import pandas as pd
import time
import datetime  
from sklearn.metrics import mean_absolute_error
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score
from math import sqrt



def pm_pwlf_assess(database, aslung="pm25", std="PM2.5"):
    Starttime = time.time()

    pm_data_array = database.copy()
    pm_data_array = pm_data_array.dropna(how='any', subset=['std_%s'%std, 'aslung_%s'%aslung])

    pm_y = pm_data_array['aslung_%s'%aslung].values
    pm_x = pm_data_array['std_%s'%std].values
    pm_pwrg = pwlf.PiecewiseLinFit(pm_x, pm_y)
    break_points = pm_pwrg.fit(2)
    pm_y_predit = pm_pwrg.predict(pm_x)
    pm_data_array['pred_%s'%aslung] = pm_y_predit
    pm_data_array.loc[:, 'pred_%s'%aslung][pm_data_array['pred_%s'%aslung] <= 0] = np.nan
    break_1 = break_points[1].round(1)
    pm_pwlf_dna = pd.DataFrame([pm_y.ravel(), pm_y_predit.ravel()]).transpose().dropna(how='any')
    pm_pwlf_r2 = r2_score(pm_pwlf_dna[0], pm_pwlf_dna[1])
    pm_pwlf_mae = mean_absolute_error(pm_pwlf_dna[0], pm_pwlf_dna[1])
    pm_pwlf_rmse = sqrt(mean_squared_error(pm_pwlf_dna[0], pm_pwlf_dna[1]))
    pm_pwlf_sample = pm_data_array.shape[0]

    pm_y_sub = pm_data_array['std_%s'%std].values
    pm_x_sub = pm_data_array['aslung_%s'%aslung].values
    pm_pwrg_sub = pwlf.PiecewiseLinFit(pm_x_sub, pm_y_sub)
    break_points_sub = pm_pwrg_sub.fit(2)
    pm_y_predit_sub = pm_pwrg_sub.predict(pm_x_sub)
    pm_data_array['pred_%s_sub'%aslung] = pm_y_predit_sub
    pm_data_array.loc[:, 'pred_%s_sub'%aslung][pm_data_array['pred_%s_sub'%aslung] <= 0] = np.nan
    break_1_sub = break_points_sub[1].round(1)
    pm_pwlf_dna_sub = pd.DataFrame([pm_y_sub.ravel(), pm_y_predit_sub.ravel()]).transpose().dropna(how='any')
    pm_pwlf_r2_sub = r2_score(pm_pwlf_dna_sub[0], pm_pwlf_dna_sub[1])
    pm_pwlf_mae_sub = mean_absolute_error(pm_pwlf_dna_sub[0], pm_pwlf_dna_sub[1])
    pm_pwlf_rmse_sub = sqrt(mean_squared_error(pm_pwlf_dna_sub[0], pm_pwlf_dna_sub[1]))
    pm_pwlf_sample_sub = pm_data_array.shape[0]

    if pm_pwlf_r2 >= 0.999:
        pm_pwlf_r2 = 0.999
    if pm_pwlf_r2_sub >= 0.999:
        pm_pwlf_r2_sub = 0.999

    # region1
    pm_pwlf_region1 = pm_data_array[(pm_data_array['std_%s'%std] <= break_1)]
    pm_y_region1 = pm_pwlf_region1['aslung_%s'%aslung]
    pred_pm_y_region1 = pm_pwlf_region1['pred_%s'%aslung]
    pm_pwlf_region1_dna = pd.DataFrame([pm_y_region1.ravel(), pred_pm_y_region1.ravel()]).transpose().dropna(
        how='any')
    pm_pwlf_region1_r2 = r2_score(pm_pwlf_region1_dna[0], pm_pwlf_region1_dna[1])
    pm_pwlf_region1_mae = mean_absolute_error(pm_pwlf_region1_dna[0], pm_pwlf_region1_dna[1])
    pm_pwlf_region1_rmse = sqrt(mean_squared_error(pm_pwlf_region1_dna[0], pm_pwlf_region1_dna[1]))
    pm_pwlf_region1_sample = pm_y_region1.shape[0]

    pm_y_region1_sub = pm_pwlf_region1['std_%s'%std]
    pred_pm_y_region1_sub = pm_pwlf_region1['pred_%s'%aslung]
    pm_pwlf_region1_dna_sub = pd.DataFrame(
        [pm_y_region1_sub.ravel(), pred_pm_y_region1_sub.ravel()]).transpose().dropna(how='any')
    pm_pwlf_region1_r2_sub = r2_score(pm_pwlf_region1_dna_sub[0], pm_pwlf_region1_dna_sub[1])
    pm_pwlf_region1_mae_sub = mean_absolute_error(pm_pwlf_region1_dna_sub[0], pm_pwlf_region1_dna_sub[1])
    pm_pwlf_region1_rmse_sub = sqrt(mean_squared_error(pm_pwlf_region1_dna_sub[0], pm_pwlf_region1_dna_sub[1]))
    pm_pwlf_region1_sample_sub = pm_y_region1.shape[0]

    # region2
    pm_pwlf_region2 = pm_data_array[(pm_data_array['std_%s'%std] > break_1)]
    pm_y_region2 = pm_pwlf_region2['aslung_%s'%aslung]
    pred_pm_y_region2 = pm_pwlf_region2['pred_%s'%aslung]
    pm_pwlf_region2_dna = pd.DataFrame([pm_y_region2.ravel(), pred_pm_y_region2.ravel()]).transpose().dropna(
        how='any')
    pm_pwlf_region2_r2 = r2_score(pm_pwlf_region2_dna[0], pm_pwlf_region2_dna[1])
    pm_pwlf_region2_mae = mean_absolute_error(pm_pwlf_region2_dna[0], pm_pwlf_region2_dna[1])
    pm_pwlf_region2_rmse = sqrt(mean_squared_error(pm_pwlf_region2_dna[0], pm_pwlf_region2_dna[1]))
    pm_pwlf_region2_sample = pm_y_region2.shape[0]

    pm_y_region2_sub = pm_pwlf_region2['std_%s'%std]
    pred_pm_y_region2_sub = pm_pwlf_region2['pred_%s'%aslung]
    pm_pwlf_region2_dna_sub = pd.DataFrame(
        [pm_y_region2_sub.ravel(), pred_pm_y_region2_sub.ravel()]).transpose().dropna(how='any')
    pm_pwlf_region2_r2_sub = r2_score(pm_pwlf_region2_dna_sub[0], pm_pwlf_region2_dna_sub[1])
    pm_pwlf_region2_mae_sub = mean_absolute_error(pm_pwlf_region2_dna_sub[0], pm_pwlf_region2_dna_sub[1])
    pm_pwlf_region2_rmse_sub = sqrt(mean_squared_error(pm_pwlf_region2_dna_sub[0], pm_pwlf_region2_dna_sub[1]))
    pm_pwlf_region2_sample_sub = pm_y_region2.shape[0]

    if pm_pwlf_region1_r2 >= 0.999:
        pm_pwlf_region1_r2 = 0.999
    if pm_pwlf_region2_r2 >= 0.999:
        pm_pwlf_region2_r2 = 0.999
    if pm_pwlf_region1_r2_sub >= 0.999:
        pm_pwlf_region1_r2_sub = 0.999
    if pm_pwlf_region2_r2_sub >= 0.999:
        pm_pwlf_region2_r2_sub = 0.999

    pm_pwlf_assess = [pm_pwrg.calc_slopes().round(3)[0], pm_pwrg.intercepts.round(3)[0], pm_pwlf_region1_mae,
                        pm_pwlf_region1_rmse, break_1,
                        pm_pwrg.calc_slopes().round(3)[1], pm_pwrg.intercepts.round(3)[1], pm_pwlf_region2_mae,
                        pm_pwlf_region2_rmse,
                        pm_pwlf_r2, pm_pwlf_mae, pm_pwlf_rmse, pm_pwlf_sample]
    pm_pwlf_assess_sub = [pm_pwrg_sub.calc_slopes().round(3)[0], pm_pwrg_sub.intercepts.round(3)[0],
                            pm_pwlf_region1_mae_sub, pm_pwlf_region1_rmse_sub, break_1_sub,
                            pm_pwrg_sub.calc_slopes().round(3)[1], pm_pwrg_sub.intercepts.round(3)[1],
                            pm_pwlf_region2_mae_sub, pm_pwlf_region2_rmse_sub,
                            pm_pwlf_r2_sub, pm_pwlf_mae_sub, pm_pwlf_rmse_sub, pm_pwlf_sample_sub]

    #pm_pwlf_assess = pd.DataFrame([pm_pwlf_assess, pm_pwlf_assess_sub])
    pm_pwlf_assess = pd.DataFrame([pm_pwlf_assess_sub])
    pm_pwlf_assess.columns = ['slope1', 'intercept1', 'region1_mae', 'region1_rmse', 'break_point1',
                                'slope2', 'intercept2', 'region2_mae', 'region2_rmse',
                                'r2', 'total_mae', 'total_rmse', 'sample']
    #pm_pwlf_assess.index = ['y_goldenstand','x_goldenstand']
    pm_pwlf_assess.index = ['y_goldenstand']
    print('need %10.5f minutes' % ((time.time() - Starttime) / 60))
    return pm_pwlf_assess, pm_data_array



