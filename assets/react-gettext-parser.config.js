module.exports = {
  componentPropsMap: {
    Translate: {
      one: 'msgid',
      many: 'msgid_plural',
      context: 'msgctxt',
      comment: 'comment',
    }
  },
  funcArgumentsMap: {
    gettext: ['msgid'],
    dgettext: [null, 'msgid'],
    ngettext: ['msgid', 'msgid_plural'],
    dngettext: [null, 'msgid', 'msgid_plural'],
    pgettext: ['msgctxt', 'msgid'],
    dpgettext: [null, 'msgctxt', 'msgid'],
    npgettext: ['msgctxt', 'msgid', 'msgid_plural'],
    dnpgettext: [null, 'msgid', 'msgid_plural'],

    translate: ['msgid', 'msgid_plural', 'msgctxt'],
  },
  trim: true,
};
