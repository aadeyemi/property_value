from sqlalchemy import create_engine


def get_engine():
    '''
    sqlalchemy engine
    '''
    database = 'postgresql://keymaker:"br0@dw@y"@localhost/tx_property_tax'
    engine = create_engine(database)
    return engine
