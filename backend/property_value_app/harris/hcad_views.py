

def hcad_views(mode, details):
    if mode == "account":
        return {"county": "harris", "account": details}
    if mode == "address":
        return {"county": "harris", "address": details}
