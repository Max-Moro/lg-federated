---
include: ["/ai-interaction"]
---
{% if tag:agent %}
${tpl:/parallel-dev/index}

---
{% endif %}
${ctx@cli:common}

---

${ctx@vscode:/vscode}

---

${ctx@intellij:/intellij}

---

{% if task %}
---

# Current task description

${task}{% endif %} 
