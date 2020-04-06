{%- from "postgresql/map.jinja" import server with context %}
{%- if server.get('enabled', False) %}

postgresql_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

{{ server.dir.config }}/pg_hba.conf:
  file.managed:
  - source: salt://postgresql/files/pg_hba.conf
  - template: jinja
  - user: postgres
  - group: postgres
  - mode: 600

{{ server.dir.config }}/postgresql.conf:
  file.managed:
  - source: salt://postgresql/files/postgresql.conf.{{ grains.os_family }}
  - template: jinja
  - user: postgres
  - group: postgres
  - defaults:
    postgresql_version: {{ server.version }}
  - mode: 600

/root/.pgpass:
  file.managed:
  - source: salt://postgresql/files/pgpass
  - template: jinja
  - user: root
  - group: root
  - mode: 600

postgresql_service:
  service.running:
  - name: {{ server.service }}
  - enable: true
  - watch:
    - file: {{ server.dir.config }}/pg_hba.conf
    - file: {{ server.dir.config }}/postgresql.conf
  - require:
    - file: /root/.pgpass

{%- for database_name, database in server.get('database', {}).items() %}
  {%- include "postgresql/_database.sls" %}

  {%- for extension_name, extension in database.get('extension', {}).items() %}
    {%- if extension.enabled %}
    {%- if extension.get('pkgs', []) %}

postgresql_{{ extension_name }}_extension_packages:
  pkg.installed:
  - names: {{ extension.get('pkgs', []) }}

    {%- endif %}

database_{{ database_name }}_{{ extension_name }}_extension_present:
  postgres_extension.present:
  - name: {{ extension_name }}
  - maintenance_db: {{ database_name }}
  - user: postgres
  - require:
    - postgres_database: {{ database_name }}

    {%- else %}

database_{{ database_name }}_{{ extension_name }}_extension_absent:
  postgres_extension.absent:
  - name: {{ extension_name }}
  - maintenance_db: {{ database_name }}
  - user: postgres
  - require:
    - postgres_database: {{ database_name }}

    {%- endif %}
  {%- endfor %}
{%- endfor %}
{%- endif %}
