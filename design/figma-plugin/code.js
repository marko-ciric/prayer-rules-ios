// Prayer Rules — builds the app's screens as native Figma layers.
//
// This is a reverse-engineering of ios/App/App/, not a redraw: the palette is
// Extensions/Theme.swift, the strings are the Swift literals, and the calendar
// data below was produced by the app's own engine rather than typed in. The
// point of a plugin (rather than an image or an SVG import) is that everything
// it makes is a real Figma object — auto-layout frames, editable text, shared
// colour styles — so the screens can actually be designed against.
//
// Run: Figma desktop → Plugins → Development → Import plugin from manifest…
// See README.md in this folder.

// ── Theme.swift ───────────────────────────────────────────────────────────
const T = {
  amber900: '#78350f', amber100: '#fef3c7', amber50: '#fffbeb',
  stone800: '#292524', stone700: '#44403c', stone600: '#57534e',
  stone500: '#78716c', stone400: '#a8a29e', stone100: '#f5f5f4',
  stone50:  '#fafaf9', red900:   '#7f1d1d', white:    '#ffffff',
  parchmentTop: '#faf5e8', parchmentBottom: '#f5efe0',
  fastDairy: '#c8a24a', fastFish: '#5f7a52',
  fastWineOil: '#a1662f', fastStrict: '#3f2f2f',
};

// FastLevel, in rawValue order — the strictness order the relaxation logic uses.
const FAST = [
  { case: 'fastFree',  sr: 'Мрсни дан',   color: null },
  { case: 'dairy',     sr: 'Сиропусно',   color: T.fastDairy },
  { case: 'fish',      sr: 'Риба',        color: T.fastFish },
  { case: 'wineOil',   sr: 'Вино и уље',  color: T.fastWineOil },
  { case: 'xerophagy', sr: 'Сухоједење',  color: T.red900 },
  { case: 'strict',    sr: 'Строги пост', color: T.fastStrict },
];

// September 2026, computed by the engine. [civilDay, julianDay, fastLevel, isGreatFeast]
const SEPTEMBER_2026 = [
  [1,19,0,0],[2,20,4,0],[3,21,0,0],[4,22,4,0],[5,23,0,0],[6,24,0,0],[7,25,0,0],
  [8,26,0,0],[9,27,4,0],[10,28,0,0],[11,29,4,0],[12,30,0,0],[13,31,0,0],[14,1,0,0],
  [15,2,0,0],[16,3,4,0],[17,4,0,0],[18,5,4,0],[19,6,0,0],[20,7,0,0],[21,8,0,1],
  [22,9,0,0],[23,10,4,0],[24,11,0,0],[25,12,4,0],[26,13,0,0],[27,14,4,1],
  [28,15,0,0],[29,16,0,0],[30,17,4,0],
];
const LEADING_BLANKS = 1;  // 1 September 2026 is a Tuesday; the grid starts Monday
const SELECTED_DAY = 11;

const PHONE_W = 390, PHONE_H = 844;

// ── plumbing ──────────────────────────────────────────────────────────────
function rgb(hex) {
  const n = parseInt(hex.slice(1), 16);
  return { r: ((n >> 16) & 255) / 255, g: ((n >> 8) & 255) / 255, b: (n & 255) / 255 };
}
const solid = (hex, opacity) => [{ type: 'SOLID', color: rgb(hex), opacity: opacity == null ? 1 : opacity }];

let DISPLAY = { family: 'Cormorant Garamond', style: 'Regular' };
let BODY = { family: 'EB Garamond', style: 'Regular' };
const styleFor = (font, weight) => ({ family: font.family, style: weight });

/** Figma ships a limited font set; fall back rather than fail on a missing face. */
async function loadFonts() {
  const wanted = [
    ['Cormorant Garamond', ['Regular', 'SemiBold', 'Bold', 'Italic']],
    ['EB Garamond', ['Regular', 'SemiBold', 'Italic']],
  ];
  let ok = true;
  for (const [family, styles] of wanted) {
    for (const style of styles) {
      try { await figma.loadFontAsync({ family, style }); }
      catch (e) { ok = false; }
    }
  }
  if (!ok) {
    for (const style of ['Regular', 'Medium', 'Semi Bold', 'Bold']) {
      await figma.loadFontAsync({ family: 'Inter', style });
    }
    DISPLAY = { family: 'Inter', style: 'Regular' };
    BODY = { family: 'Inter', style: 'Regular' };
    figma.notify('Cormorant / EB Garamond unavailable — built with Inter.');
  }
  return ok;
}

function weightName(font, weight) {
  if (font.family !== 'Inter') return weight;
  return { Regular: 'Regular', SemiBold: 'Semi Bold', Bold: 'Bold', Italic: 'Regular' }[weight] || 'Regular';
}

function text(chars, o) {
  o = o || {};
  const font = o.display ? DISPLAY : BODY;
  const node = figma.createText();
  node.fontName = styleFor(font, weightName(font, o.weight || 'Regular'));
  node.characters = chars;
  node.fontSize = o.size || 15;
  node.fills = solid(o.color || T.stone800, o.opacity);
  if (o.tracking) node.letterSpacing = { unit: 'PIXELS', value: o.tracking };
  if (o.lineHeight) node.lineHeight = { unit: 'PIXELS', value: o.lineHeight };
  if (o.align) node.textAlignHorizontal = o.align;
  if (o.width) { node.textAutoResize = 'HEIGHT'; node.resize(o.width, node.height); }
  else node.textAutoResize = 'WIDTH_AND_HEIGHT';
  if (o.name) node.name = o.name;
  return node;
}

function frame(name, o) {
  o = o || {};
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = o.horizontal ? 'HORIZONTAL' : 'VERTICAL';
  f.primaryAxisSizingMode = o.fixedMain ? 'FIXED' : 'AUTO';
  f.counterAxisSizingMode = o.width ? 'FIXED' : 'AUTO';
  f.itemSpacing = o.gap == null ? 0 : o.gap;
  const p = o.pad || 0;
  f.paddingTop = o.padY == null ? p : o.padY;
  f.paddingBottom = o.padY == null ? p : o.padY;
  f.paddingLeft = o.padX == null ? p : o.padX;
  f.paddingRight = o.padX == null ? p : o.padX;
  f.fills = o.fill ? solid(o.fill, o.fillOpacity) : [];
  if (o.stroke) { f.strokes = solid(o.stroke, o.strokeOpacity); f.strokeWeight = o.strokeWeight || 1; }
  if (o.align) f.counterAxisAlignItems = o.align;
  if (o.justify) f.primaryAxisAlignItems = o.justify;
  if (o.width) f.resize(o.width, f.height || 1);
  if (o.height) { f.primaryAxisSizingMode = 'FIXED'; f.resize(f.width || 1, o.height); }
  if (o.clip != null) f.clipsContent = o.clip;
  return f;
}

function add(parent, children) {
  for (const c of children) if (c) parent.appendChild(c);
  return parent;
}

function rule(width, hex, opacity, height) {
  const r = figma.createRectangle();
  r.name = 'rule';
  r.resize(width, height || 1);
  r.fills = solid(hex, opacity);
  return r;
}

/** The four-pointed diamond from OrnamentView.swift, at 24pt scale. */
function ornament(size) {
  const s = (size || 14) / 24;
  const node = figma.createNodeFromSvg(
    '<svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path d="M12 2 L13 10 L21 11 L13 12 L12 22 L11 12 L3 11 L11 10 Z" fill="' + T.amber900 + '"/>' +
    '<circle cx="12" cy="11" r="1.5" fill="' + T.amber50 + '"/></svg>');
  node.name = 'Ornament';
  node.resize(24 * s, 24 * s);
  node.opacity = 0.7;
  return node;
}

const label = (chars) => text(chars, {
  size: 11, tracking: 2.2, color: T.amber900, opacity: 0.7, name: 'section label',
});

function card(title, children, width) {
  const f = frame(title, {
    width: width, pad: 16, gap: 10, fill: T.white, fillOpacity: 0.65,
    stroke: T.amber900, strokeOpacity: 0.18,
  });
  return add(f, [title ? label(title.toUpperCase()) : null].concat(children));
}

function chevronRow(title, subtitle, width) {
  const row = frame(title, { horizontal: true, width: width, padY: 10, justify: 'SPACE_BETWEEN', align: 'CENTER' });
  const stack = frame('text', { gap: 3 });
  add(stack, [
    text(title, { display: true, weight: 'SemiBold', size: 18, color: T.amber900 }),
    subtitle ? text(subtitle, { size: 13, color: T.stone500 }) : null,
  ]);
  add(row, [stack, text('›', { size: 21, color: T.amber900, opacity: 0.4 })]);
  return row;
}

// ── shared colour styles ──────────────────────────────────────────────────
function buildStyles() {
  const made = [];
  const paint = (name, hex) => {
    const s = figma.createPaintStyle();
    s.name = name; s.paints = solid(hex); made.push(s);
  };
  for (const key of Object.keys(T)) {
    if (key.indexOf('parchment') === 0) continue;
    paint((key.indexOf('fast') === 0 ? 'Fast/' : 'Theme/') + key, T[key]);
  }
  const g = figma.createPaintStyle();
  g.name = 'Theme/parchment';
  g.paints = [{
    type: 'GRADIENT_LINEAR',
    gradientTransform: [[0, 1, 0], [-1, 0, 1]],
    gradientStops: [
      { position: 0, color: Object.assign({ a: 1 }, rgb(T.parchmentTop)) },
      { position: 1, color: Object.assign({ a: 1 }, rgb(T.parchmentBottom)) },
    ],
  }];
  made.push(g);
  return made;
}

function screen(name, x) {
  const f = frame(name, { width: PHONE_W, height: PHONE_H, clip: true, fixedMain: true });
  f.fills = [{
    type: 'GRADIENT_LINEAR',
    gradientTransform: [[0, 1, 0], [-1, 0, 1]],
    gradientStops: [
      { position: 0, color: Object.assign({ a: 1 }, rgb(T.parchmentTop)) },
      { position: 1, color: Object.assign({ a: 1 }, rgb(T.parchmentBottom)) },
    ],
  }];
  f.cornerRadius = 34;
  f.x = x; f.y = 0;
  return f;
}

const body = (gap) => frame('scroll', {
  width: PHONE_W, padX: 16, padY: 14, gap: gap == null ? 22 : gap,
});
const INNER = PHONE_W - 32;

function dateHeader() {
  const f = frame('date', { width: INNER, gap: 6, align: 'CENTER' });
  const toneRow = frame('season', { horizontal: true, gap: 10, align: 'CENTER', padY: 6 });
  add(toneRow, [
    rule(28, T.amber900, 0.3),
    text('ГЛАС 5 · 14. СЕДМИЦА ПО ДУХОВИМА', { size: 11, tracking: 1.4, color: T.amber900, opacity: 0.65 }),
    rule(28, T.amber900, 0.3),
  ]);
  return add(f, [
    text('ПЕТАК', { size: 12, tracking: 2.6, color: T.amber900, opacity: 0.8 }),
    text('11. септембра 2026.', { display: true, weight: 'Bold', size: 30, color: T.amber900 }),
    text('29. август по црквеном календару', { size: 14, color: T.stone600, weight: 'Italic' }),
    toneRow,
  ]);
}

function fastBadge() {
  const f = frame('fast', {
    width: INNER, pad: 14, gap: 6, fill: T.white, fillOpacity: 0.7,
    stroke: T.amber900, strokeOpacity: 0.18,
  });
  const row = frame('row', { horizontal: true, gap: 10, align: 'CENTER', width: INNER - 32 });
  const dot = figma.createEllipse();
  dot.resize(10, 10); dot.fills = solid(T.red900); dot.name = 'fast dot';
  add(row, [
    dot,
    text('Сухоједење', { display: true, weight: 'SemiBold', size: 19, color: T.stone800 }),
  ]);
  return add(f, [
    row,
    text('Усековање главе Св. Јована Крститеља', { size: 12, color: T.stone500, weight: 'Italic' }),
    text('Сухоједење — посна јела без уља и вина.', { size: 14, color: T.stone600, width: INNER - 32 }),
  ]);
}

function commemorationCard() {
  const row = frame('feast', { horizontal: true, gap: 10, width: INNER - 32 });
  const stack = frame('name', { gap: 2, width: INNER - 32 - 24 });
  add(stack, [
    text('Усековање главе Св. Јована Крститеља', {
      display: true, weight: 'SemiBold', size: 17, color: T.amber900, width: INNER - 56,
    }),
    text('Усековање', { size: 13, color: T.stone500, weight: 'Italic' }),
  ]);
  add(row, [ornament(14), stack]);
  return card('Спомен дана', [row], INNER);
}

function pendingNote(chars) {
  return text(chars, { size: 13, color: T.stone500, weight: 'Italic', width: INNER - 32 });
}

// ── screen 1: Today ───────────────────────────────────────────────────────
function buildToday() {
  const s = screen('Данас — Today', 0);
  const b = body();

  const top = frame('top', { horizontal: true, width: INNER, justify: 'SPACE_BETWEEN', align: 'CENTER' });
  const toggle = frame('SR / EN', { horizontal: true, gap: 4 });
  for (const [code, on] of [['SR', true], ['EN', false]]) {
    const chip = frame(code, {
      padX: 10, padY: 5, fill: on ? T.amber900 : T.white,
      stroke: T.amber900, strokeOpacity: on ? 1 : 0.3, align: 'CENTER',
    });
    chip.cornerRadius = 2;
    add(chip, [text(code, { size: 11, tracking: 0.7, color: on ? T.amber50 : T.amber900 })]);
    add(toggle, [chip]);
  }
  add(top, [text('ДАНАС', { size: 11, tracking: 2.4, color: T.amber900, opacity: 0.6 }), toggle]);

  const hours = [
    ['Први час', 'Псалам 5 · 89 · 100'], ['Трећи час', 'Псалам 16 · 24 · 50'],
    ['Шести час', 'Псалам 53 · 54 · 90'], ['Девети час', 'Псалам 83 · 84 · 85'],
  ].map(([t, s2]) => chevronRow(t, s2, INNER - 32));

  const kath = [];
  for (const [group, items] of [['ЈУТРЕЊЕ', [['19', '134–142'], ['20', '143–150']]],
                                ['ВЕЧЕРЊЕ', [['18', '119–133']]]]) {
    kath.push(text(group, { size: 11, tracking: 2.2, color: T.amber900, opacity: 0.7 }));
    for (const [n, range] of items) {
      const row = frame('Катизма ' + n, {
        horizontal: true, gap: 10, padX: 10, padY: 8, width: INNER - 32,
        align: 'CENTER', fill: T.amber50, fillOpacity: 0.6, stroke: T.amber900, strokeOpacity: 0.18,
      });
      add(row, [
        text('Катизма ' + n, { display: true, weight: 'SemiBold', size: 16, color: T.amber900 }),
        text(range, { size: 14, color: T.stone600 }),
      ]);
      kath.push(row);
    }
  }

  const div = frame('divider', { horizontal: true, gap: 16, align: 'CENTER', padY: 14, width: INNER, justify: 'CENTER' });
  add(div, [rule(110, T.amber900, 0.3), ornament(18), rule(110, T.amber900, 0.3)]);

  add(b, [
    top, dateHeader(), fastBadge(), commemorationCard(),
    card('Служба дана', [pendingNote(
      'Служба овог дана се припрема. Минеј се уноси постепено — тропар и кондак се појављују чим буду унети.')], INNER),
    card('Молитвено правило', [
      chevronRow('Јутарње молитве', 'Молитвено правило по устајању', INNER - 32),
      chevronRow('Вечерње молитве', 'Молитвено правило пред спавање', INNER - 32),
    ], INNER),
    card('Часови', hours, INNER),
    card('Катизме дана', kath, INNER),
    text('Правило поста дато је по општем типику. За своје правило посаветуј се са духовником.', {
      size: 12, color: T.stone500, weight: 'Italic', align: 'CENTER', width: INNER,
    }),
    div,
    text('Алилуја.', { display: true, weight: 'Italic', size: 15, color: T.amber900, opacity: 0.7, align: 'CENTER', width: INNER }),
  ]);
  s.appendChild(b);
  return s;
}

// ── screen 2: Calendar ────────────────────────────────────────────────────
function buildCalendar() {
  const s = screen('Календар — Calendar', PHONE_W + 60);
  const b = body();

  const head = frame('month', { horizontal: true, width: INNER, justify: 'SPACE_BETWEEN', align: 'CENTER' });
  const title = frame('title', { gap: 2, align: 'CENTER' });
  add(title, [
    text('септембар', { display: true, weight: 'Bold', size: 26, color: T.amber900 }),
    text('2026', { size: 12, tracking: 2, color: T.stone500 }),
  ]);
  add(head, [
    text('‹', { size: 17, color: T.amber900 }), title, text('›', { size: 17, color: T.amber900 }),
  ]);

  const cellW = (INNER - 12) / 7;  // six 2pt gaps
  const weekdays = frame('weekdays', { horizontal: true, gap: 2, width: INNER });
  for (const d of ['По', 'Ут', 'Ср', 'Че', 'Пе', 'Су', 'Не']) {
    const c = frame(d, { width: cellW, align: 'CENTER' });
    add(c, [text(d.toUpperCase(), { size: 11, tracking: 0.8, color: T.amber900, opacity: 0.6 })]);
    add(weekdays, [c]);
  }

  const grid = frame('grid', { gap: 2, width: INNER });
  let row = null;
  const cells = [];
  for (let i = 0; i < LEADING_BLANKS; i++) cells.push(null);
  for (const d of SEPTEMBER_2026) cells.push(d);
  while (cells.length % 7 !== 0) cells.push(null);

  cells.forEach((d, i) => {
    if (i % 7 === 0) { row = frame('week', { horizontal: true, gap: 2, width: INNER }); add(grid, [row]); }
    if (!d) { add(row, [frame('·', { width: cellW, height: 54 })]); return; }
    const [civil, julian, level, great] = d;
    const selected = civil === SELECTED_DAY;
    const cell = frame(String(civil), {
      width: cellW, height: 54, align: 'CENTER', justify: 'CENTER', gap: 2, clip: true,
      fill: selected ? T.amber900 : T.white, fillOpacity: selected ? 1 : 0.55,
      stroke: T.amber900, strokeOpacity: selected ? 1 : 0.12, strokeWeight: selected ? 1.5 : 1,
    });
    const top = frame('nums', { horizontal: true, gap: 3, align: 'CENTER', justify: 'CENTER', width: cellW });
    add(top, [
      text(String(civil), {
        display: true, weight: great ? 'Bold' : 'Regular', size: 17,
        color: selected ? T.amber50 : (great ? T.red900 : T.stone800),
      }),
      text(String(julian), { size: 9, color: selected ? T.amber50 : T.stone400, opacity: selected ? 0.8 : 1 }),
    ]);
    add(cell, [top]);
    if (FAST[level].color) {
      const band = rule(cellW, FAST[level].color, 1, 3);
      band.name = 'fast band — .' + FAST[level].case;
      add(cell, [band]);
    }
    add(row, [cell]);
  });

  const legend = frame('Ознаке поста', { gap: 6, width: INNER });
  add(legend, [text('ОЗНАКЕ ПОСТА', { size: 10, tracking: 2, color: T.amber900, opacity: 0.6 })]);
  for (let i = 0; i < FAST.length; i += 3) {
    const r = frame('row', { horizontal: true, gap: 12, width: INNER, align: 'CENTER' });
    for (const f of FAST.slice(i, i + 3)) {
      const item = frame(f.sr, { horizontal: true, gap: 5, align: 'CENTER', width: (INNER - 24) / 3 });
      add(item, [
        f.color ? rule(10, f.color, 1, 3) : rule(10, T.stone400, 0.35, 3),
        text(f.sr, { size: 11, color: T.stone600 }),
      ]);
      add(r, [item]);
    }
    add(legend, [r]);
  }

  const div = frame('divider', { horizontal: true, gap: 16, align: 'CENTER', padY: 14, width: INNER, justify: 'CENTER' });
  add(div, [rule(110, T.amber900, 0.3), ornament(18), rule(110, T.amber900, 0.3)]);

  add(b, [head, weekdays, grid, legend, div, dateHeader(), fastBadge(), commemorationCard()]);
  s.appendChild(b);
  return s;
}

// ── screen 3: the service reader ──────────────────────────────────────────
function buildHour() {
  const s = screen('Први час — ServiceView', (PHONE_W + 60) * 2);

  const bar = frame('top bar', {
    horizontal: true, width: PHONE_W, padX: 16, padY: 12,
    justify: 'SPACE_BETWEEN', align: 'CENTER', fill: T.stone50, fillOpacity: 0.95,
  });
  const ctl = frame('font', { horizontal: true, gap: 10, align: 'CENTER' });
  add(ctl, ['−', 'Aa', '+'].map((c) => text(c, { size: 14, color: T.amber900 })));
  add(bar, [text('‹ Назад', { size: 15, color: T.amber900 }), ctl]);

  const b = body(26);

  const title = frame('title', { width: INNER, gap: 6, align: 'CENTER' });
  add(title, [
    text('Први час', { display: true, weight: 'Bold', size: 34, color: T.amber900 }),
    text('Око седам часова ујутро', { size: 14, color: T.stone600, weight: 'Italic' }),
  ]);

  const div = frame('divider', { horizontal: true, gap: 16, align: 'CENTER', padY: 14, width: INNER, justify: 'CENTER' });
  add(div, [rule(110, T.amber900, 0.3), ornament(18), rule(110, T.amber900, 0.3)]);

  function prayer(name, chars) {
    const f = frame(name || 'prayer', { gap: 6, width: INNER });
    return add(f, [
      name ? text(name, { display: true, weight: 'SemiBold', size: 15, color: T.amber900, opacity: 0.85 }) : null,
      text(chars, { size: 17, color: T.stone800, lineHeight: 27, width: INNER }),
    ]);
  }
  const rubric = (chars) => text(chars, { size: 14, color: T.red900, opacity: 0.75, weight: 'Italic', width: INNER });

  function psalmRow(n, opening) {
    const f = frame('Псалам ' + n, {
      horizontal: true, gap: 12, pad: 12, width: INNER,
      fill: T.amber50, fillOpacity: 0.6, stroke: T.amber900, strokeOpacity: 0.2,
    });
    const stack = frame('opening', { gap: 2, width: INNER - 24 - 40 - 12 - 20 });
    add(stack, [
      text('ПСАЛАМ', { size: 11, tracking: 1.4, color: T.amber900, opacity: 0.6 }),
      text(opening + '…', { size: 15, color: T.stone700, width: INNER - 100 }),
    ]);
    return add(f, [
      text(String(n), { display: true, weight: 'SemiBold', size: 24, color: T.amber900 }),
      stack,
      text('›', { size: 21, color: T.amber900, opacity: 0.4 }),
    ]);
  }

  // The whole point of the .pending case: a named gap, not a silent omission.
  const gap = frame('.pending — Тропари дана', {
    horizontal: true, gap: 10, pad: 12, width: INNER,
    fill: T.stone100, fillOpacity: 0.7, stroke: T.stone400, strokeOpacity: 0.7,
  });
  gap.dashPattern = [3, 3];
  const gapText = frame('text', { gap: 2, width: INNER - 24 - 20 });
  add(gapText, [
    text('Тропар и кондак дана, по Минеју.', { size: 15, color: T.stone600, width: INNER - 60 }),
    text('Текст се припрема', { size: 11, color: T.stone400, weight: 'Italic' }),
  ]);
  add(gap, [text('⧗', { size: 12, color: T.stone400 }), gapText]);

  function section(name, children) {
    const f = frame(name, { gap: 14, width: INNER, align: 'CENTER' });
    return add(f, [label(name.toUpperCase())].concat(children));
  }

  add(b, [
    title, div,
    section('Почетак', [
      prayer(null, 'У име Оца и Сина и Светога Духа. Амин.'),
      prayer(null, 'Слава Теби, Боже наш, слава Теби.'),
      prayer('Царе Небески', 'Царе Небески, Утешитељу, Душе Истине, Који си свуда присутан и све испуњаваш, Ризницо добара и Животодавче, дођи и усели се у нас, и очисти нас од сваке нечистоте, и спаси, Благи, душе наше.'),
      rubric('Трисвето — трипут:'),
      prayer('Трисвето', 'Свети Боже, Свети Крепки, Свети Бесмртни, помилуј нас.'),
    ]),
    section('Псалми часа', [
      psalmRow(5, 'Речи моје чуј, Господе, разуми вапај мој'),
      psalmRow(89, 'Господе, уточиште си нам био из нараштаја у нараштај'),
      psalmRow(100, 'Милост и суд певаћу Ти, Господе'),
      rubric('Слава… и сада… Алилуја, алилуја, алилуја, слава Теби, Боже. (трипут)'),
    ]),
    section('Тропари дана', [gap]),
    section('Завршетак', [
      prayer('Богородице Дјево', 'Богородице Дјево, радуј се, благодатна Маријо, Господ је с Тобом; благословена си Ти међу женама и благословен је плод утробе Твоје, јер си родила Спаса душа наших.'),
      rubric('Господе, помилуј. (четрдесет пута)'),
    ]),
  ]);

  const stack = frame('screen', { width: PHONE_W, height: PHONE_H, fixedMain: true, clip: true });
  stack.fills = s.fills;
  stack.cornerRadius = 34;
  stack.x = s.x; stack.y = 0;
  add(stack, [bar, b]);
  s.remove();
  return stack;
}

// ── run ───────────────────────────────────────────────────────────────────
(async () => {
  await loadFonts();
  buildStyles();
  const screens = [buildToday(), buildCalendar(), buildHour()];
  for (const s of screens) figma.currentPage.appendChild(s);
  figma.currentPage.selection = screens;
  figma.viewport.scrollAndZoomIntoView(screens);
  figma.closePlugin('Built ' + screens.length + ' screens and the Theme colour styles.');
})();
