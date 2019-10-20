import pandas as pd
import numpy as np
import json

# cost and design is Remodel
# TTL cost factor is exterior wall, foundation, and heating_cooling

SUBJECT_COLS = ['building_number', 'depreciation_value', 'impr_sq_ft',
                'nbhd_factor', 'size_index', 'percent_complete',
                'lump_sum_adj', 'story_height_index', 'cdu', 'grd',
                'heating_cooling', 'foundation', 'exterior_wall',
                'cost_and_design', 'land_value', 'improvement_value',
                'extra_features_value', 'ag_value', 'assessed_value']

DEP_X = 'depreciation_value_x'
DEP_Y = 'depreciation_value_y'
LSUM_X = 'lump_sum_adj_x'
LSUM_Y = 'lump_sum_adj_y'


def merge_subject_right(subject_df, df):
    '''
    returns a dataframe with subject appended 
    to right of each comparable
    '''

    return pd.merge(
        df,
        subject_df[SUBJECT_COLS],
        on=['building_number'],
        how='left'
    )


def less_lump_sum(df, depreciation, lump_sum):
    '''
    returns improvement less lumpsum
    '''
    return df[depreciation] - df[lump_sum]


def getTtl(df, which):
    exw = df['exterior_wall_' + which]
    hac = df['heating_cooling_' + which]
    fdn = df['foundation_' + which]
    ttl = exw + hac + fdn
    return ttl


def compute_adj(subject_df, df):

    merged = merge_subject_right(subject_df, df)
    impr_less_lsum_comp = less_lump_sum(merged, DEP_X, LSUM_X)
    merged['impr_less_lsum_comp'] = impr_less_lsum_comp

    # improvement adjustments
    ttl = getTtl(merged, 'y') / getTtl(merged, 'x')
    rmd = merged['cost_and_design_y'] * 0 + 1
    grd = merged['grd_y'] / merged['grd_x']
    szx = merged['size_index_y'] / merged['size_index_x']
    nbh = merged['nbhd_factor_y'] / merged['nbhd_factor_x']
    cdu = merged['cdu_y'] / merged['cdu_x']

    new_impr_less_lsum = impr_less_lsum_comp * ttl * rmd * grd * szx * nbh * cdu
    impr_less_lsum_adj = new_impr_less_lsum - impr_less_lsum_comp
    merged['new_impr_less_lsum'] = new_impr_less_lsum
    merged['impr_less_lsum_adj'] = impr_less_lsum_adj

    # linear size adjustment
    comp_adj_price_per_sqft = new_impr_less_lsum / merged['impr_sq_ft_x']
    size_diff = merged['impr_sq_ft_y'] - merged['impr_sq_ft_x']
    size_diff_adj = size_diff * comp_adj_price_per_sqft
    merged['size_diff_adj'] = size_diff_adj

    # lump sum adjustment
    lsum_x_new = merged['lump_sum_adj_x'] * rmd * grd * nbh * cdu
    lsum_y_new = merged['lump_sum_adj_y'] * merged['cdu_y']
    lsum_adj = lsum_y_new - lsum_x_new
    merged['lsum_x_new'] = lsum_x_new
    merged['lsum_y_new'] = lsum_y_new
    merged['lsum_adj'] = lsum_adj

    # all improvement-based adjustments
    merged['impr_adjustments'] = impr_less_lsum_adj + size_diff_adj + lsum_adj

    # land adjustment
    merged['land_adjustment'] = merged['land_value_y'] - merged['land_value_x']

    # extra_features adjustment
    merged['extra_features_adjustment'] = merged['extra_features_value_y'] - \
        merged['extra_features_value_x']

    # ag adjustment
    merged['ag_value_adjustment'] = merged['ag_value_y'] - merged['ag_value_x']

    # new appraised value
    merged['adj_appraisal'] = \
        merged['assessed_value_x'] + \
        merged['land_adjustment'] + \
        merged['extra_features_adjustment'] + \
        merged['ag_value_adjustment'] + \
        merged['impr_adjustments']

    df = merged.sort_values(by=['adj_appraisal'], ascending=[True])
    buildings = df_to_list(merged)

    print([o['total'] for o in buildings])

    return buildings


def df_to_list(df):
    df_list = df.to_dict('records')
    df_list.sort(key=lambda x: x['building_number'], reverse=False)

    out = dict()
    for obj in df_list:
        key = obj['account']
        if key in out:
            out[key]['buildings'].append(obj)
            out[key]['total'] = out[key]['total'] + obj['adj_appraisal']
        else:
            out[key] = dict()
            out[key]['buildings'] = [obj]
            out[key]['total'] = obj['adj_appraisal']

    output = [value for key, value in out.items()]
    output.sort(key=lambda x: x['total'], reverse=False)

    if len(output) <= 5:
        return output

    return output[:5]
