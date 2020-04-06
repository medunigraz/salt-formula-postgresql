{%- for user in database.get('users', []) %}
postgresql_user_{{ svr_name|default('localhost') }}_{{ database_name }}_{{ user.name }}:
  postgres_user.present:
    - name: {{ user.name }}
    - user: postgres
    {% if user.get('superuser', False) %}
    - superuser: enabled
    {% endif %}
    {% if user.get('createdb', False) %}
    - createdb: enabled
    {% endif %}
    - password: {{ user.password }}
    - require:
        - service: postgresql_service
    {%- if admin is defined %}
    {%- for k, p in admin.items() %}
    - db_{{ k }}: {{ p }}
    {%- endfor %}
    - user: root
    {%- endif %}
{%- endfor %}

postgresql_database_{{ svr_name|default('localhost') }}_{{ database_name }}:
  postgres_database.present:
    - name: {{ database.get('name', database_name) }}
    - encoding: {{ database.encoding }}
    - user: postgres
    {%- if database.template is defined %}
    - template: {{ database.template }}
    {%- endif %}
    - owner: {% for user in database.users %}{% if loop.first %}{{ user.name }}{% endif %}{% endfor %}
    - require:
        {%- for user in database.users %}
        - postgres_user: postgresql_user_{{ svr_name|default('localhost') }}_{{ database_name }}_{{ user.name }}
        {%- endfor %}
    {%- if admin is defined %}
    {%- for k, p in admin.items() %}
    - db_{{ k }}: {{ p }}
    {%- endfor %}
    - user: root
    {%- endif %}

