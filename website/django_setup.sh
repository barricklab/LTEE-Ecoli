#Using Django 1.9.4
django-admin startproject LTEE_Ecoli_site
cd LTEE_Ecoli_site

python manage.py runserver
python manage.py startapp LTEE_Ecoli

#Copy this directory into the webserver

#for testing locally 

python manage.py makemigrations LTEE_Ecoli
python manage.py migrate
pip install django_tables2
