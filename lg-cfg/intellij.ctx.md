{% if tag:agent %}
${tpl@intellij:agent/index}

---
{% endif %}
${ctx@cli:common}
{% if tag:ref %}
---

${ctx@vscode:vscode}
{% endif %} 
---

${ctx@intellij:intellij}
{% if task %}
---

# Current task description

${task}{% endif %} 
{% if tag:agent %}
${tpl@intellij:agent/footer}
{% endif %}