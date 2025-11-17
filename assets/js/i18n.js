import Gettext from 'node-gettext';

import { messages } from './messages';

const DOMAIN = 'js';
const gt = new Gettext();

for (const [locale, translations] of Object.entries(messages)) {
  gt.addTranslations(locale, DOMAIN, translations);
}

gt.setTextDomain(DOMAIN);

const htmlTag = document.querySelector('html');
let lang = 'en';
if (htmlTag.attributes.lang) {
  lang = htmlTag.attributes.lang.value.replace('-', '_');
}

gt.setLocale(lang);

export { gt };
