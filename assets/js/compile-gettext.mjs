import fs from 'fs';
import path from 'path';
import parser from 'gettext-parser';
const { po, mo } = parser;

const translationsDir = '../priv/gettext';
const locales = ['en', 'ja', 'zh_TW'];
const domain = 'js';

const translations = {};

locales.forEach((locale) => {
  const fileName = `LC_MESSAGES/${domain}.po`;
  const translationsFilePath = path.join(translationsDir, locale, fileName);
  const translationsContent = fs.readFileSync(translationsFilePath);

  const parsedTranslations = po.parse(translationsContent, 'utf8');
  translations[locale] = parsedTranslations;
});

const content = `// Auto-generated, do not edit
export const messages = ${ JSON.stringify(translations) };
`;

try {
  fs.writeFileSync('js/messages.js', content);
} catch (err) {
  console.error(err);
}
