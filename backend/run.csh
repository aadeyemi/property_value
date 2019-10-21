django-admin startproject property_value_proj
cd property_value_proj/
python manage.py startapp property_value_app 
pip install django-cors-headers
pip install psycopg2

create-react-app property_value_app
git ls-tree --full-tree -r --name-only HEAD