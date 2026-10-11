---
layout: page
title: Contact
permalink: /contact/
---
Get in touch:

- Email: [{{ site.data.cv.contact.email }}](mailto:{{ site.data.cv.contact.email }})
- GitHub: [{{ site.data.cv.contact.github }}]({{ site.data.cv.contact.github_url }})
{%- if site.data.cv.contact.linkedin_url and site.data.cv.contact.linkedin_url != "" %}
- LinkedIn: [{{ site.data.cv.contact.linkedin }}]({{ site.data.cv.contact.linkedin_url }})
{%- endif %}
- Location: {{ site.data.cv.contact.location }}
