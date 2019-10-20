import sys
from sqlalchemy import text
import pandas as pd
import re
import numpy as np
# from utilities import mono_building_account, multi_building_account
# from utilities import get_candidate_subject_accounts
from compute import compute_adj
from db_engine import get_engine


def get_candidate_subject_accounts(df):
    '''
    get list of unique accounts in dataframe
    to suject possible acounts to user if address provided
    yields multiple accounts 
    '''
    unique_accounts = df['account'].unique()
    return unique_accounts


def get_comparables(condition):
    '''
    run query to extract comparables from database
    with user provided condition
    '''
    script = '10_comparables.sql'
    try:
        with open(script) as file:
            query = file.read()
    except Exception:
        return None
    query = re.sub(r'_CONDITION_', condition, query)
    comparables = pd.read_sql_query(text(query), get_engine())
    return comparables


def main():
    '''
    main function - process user request
    '''
    # define subject condition
    subject_condition = "account = 22610000012"  # 4-building example (multi)
    subject_condition = "account = 1110320010029"  # 1-building example
    subject_condition = "site_addr_1 = '12309 ormandy st'"  # 1-building example
    subject_condition = "account = 21660000009"  # 2-building example (multi)
    subject_condition = "account = 1297540010001"  # 1-building example

    # get comparables data
    comps_df = get_comparables(subject_condition)
    subject_df = comps_df[comps_df['is_subject'] == 1]
    num_subject_accounts = subject_df['account'].nunique()

    # assess number of subject accounts found and proceed
    if num_subject_accounts == 1:
        num_buildings = subject_df['num_buildings'].iloc[0]
        valid_comps_df = comps_df[comps_df['num_buildings'] == num_buildings]
        compute_adj(subject_df, valid_comps_df)
    else:
        # multiple accounts with same address found
        get_candidate_subject_accounts(subject_df)


if __name__ == "__main__":
    main()
