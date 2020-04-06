{%- if pillar.postgresql is defined %}
include:
{% if pillar.postgresql.server is defined %}
- postgresql.server
{% endif %}
{% if pillar.postgresql.client is defined %}
- postgresql.client
{% endif %}
{% endif %}
