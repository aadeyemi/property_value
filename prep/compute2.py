import pandas as pd
import numpy as np

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


def nan_2_zero(item):
    '''
    replace inf with nan, then replace nan with 0
    '''
    return item.replace([np.inf, -np.inf], np.nan).fillna(0)


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


def compute_adj(subject_df, df):

    merged = merge_subject_right(subject_df, df)

    # adjustments
    exw_ = merged['exterior_wall_y'] / merged['exterior_wall_x']
    hac_ = merged['heating_cooling_y'] / merged['heating_cooling_x']
    fdn_ = merged['foundation_y'] / merged['foundation_x']
    cad_ = merged['cost_and_design_y'] / merged['cost_and_design_x']
    grd_ = merged['grd_y'] / merged['grd_x']
    szx_ = merged['size_index_y'] / merged['size_index_x']
    nbh_ = merged['nbhd_factor_y'] / merged['nbhd_factor_x']
    cdu_ = merged['cdu_y'] / merged['cdu_x']

    impr_less_lsum_comp = less_lump_sum(merged, DEP_X, LSUM_X)

    exw = nan_2_zero(impr_less_lsum_comp * exw_ - impr_less_lsum_comp)
    hac = nan_2_zero(impr_less_lsum_comp * hac_ - impr_less_lsum_comp)
    fdn = nan_2_zero(impr_less_lsum_comp * fdn_ - impr_less_lsum_comp)
    cad = nan_2_zero(impr_less_lsum_comp * cad_ - impr_less_lsum_comp)
    grd = nan_2_zero(impr_less_lsum_comp * grd_ - impr_less_lsum_comp)
    szx = nan_2_zero(impr_less_lsum_comp * szx_ - impr_less_lsum_comp)
    nbh = nan_2_zero(impr_less_lsum_comp * nbh_ - impr_less_lsum_comp)
    cdu = nan_2_zero(impr_less_lsum_comp * cdu_ - impr_less_lsum_comp)

    # size
    impr_less_lsum_subject = less_lump_sum(merged, DEP_Y, LSUM_Y)

    subject_price_per_sqft = impr_less_lsum_subject / merged['impr_sq_ft_y']
    size_subject_minus_comp = merged['impr_sq_ft_y'] - merged['impr_sq_ft_x']
    size_adj_per_sqft = size_subject_minus_comp * subject_price_per_sqft

    # merged.to_csv('merged.csv')

    # adjustments
    adjustments = exw + hac + fdn + cad + grd + szx + nbh + cdu + size_adj_per_sqft
    merged['adjustments'] = adjustments

    merged['adj_appraisal'] = \
        merged['improvement_value_x'] + \
        merged['land_value_y'] + \
        merged['extra_features_value_y'] + \
        merged['ag_value_y'] + \
        merged['adjustments']

    # result
    print(merged.groupby(['account', 'improvement_value_x'])['adjustments']
          .agg('sum').reset_index()
          .sort_values(by=['adjustments'], ascending=[True]))

    print(merged.sort_values(by=['adj_appraisal'], ascending=[True]))
