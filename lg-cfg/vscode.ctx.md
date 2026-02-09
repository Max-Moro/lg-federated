---
include: ["/ai-interaction", "/using-references"]
---
{% if tag:agent %}
${tpl@vscode:agent/index}

---
{% endif %}
${ctx@cli:common}
{% if tag:ref %}
---

${ctx@intellij:intellij}
{% endif %} 
---

${ctx@vscode:vscode}
{% if task %}
---

# Current task description

${task}{% endif %}
{% if tag:agent %}
${tpl@vscode:agent/footer}
{% endif %}