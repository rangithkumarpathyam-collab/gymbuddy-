import json

with open('figma_deep.json', 'r', encoding='utf-8-sig') as f:
    data = json.load(f)

pages = data['document']['children']
page = pages[0]

screens = [c for c in page['children'] if isinstance(c, dict) and 'design system' not in c.get('name','').lower()]

def walk_colors(node, bag):
    if not isinstance(node, dict): return
    for fill in node.get('fills', []):
        if not isinstance(fill, dict): continue
        if fill.get('type') == 'SOLID' and fill.get('visible', True) is not False:
            c = fill.get('color', {})
            if isinstance(c, dict):
                r,g,b = int(c.get('r',0)*255), int(c.get('g',0)*255), int(c.get('b',0)*255)
                a = round(c.get('a', 1.0), 2)
                bag.add((r,g,b,a))
    for stroke in node.get('strokes', []):
        if not isinstance(stroke, dict): continue
        if stroke.get('type') == 'SOLID':
            c = stroke.get('color', {})
            if isinstance(c, dict):
                r,g,b = int(c.get('r',0)*255), int(c.get('g',0)*255), int(c.get('b',0)*255)
                bag.add((r,g,b,1.0))
    for child in node.get('children', []):
        walk_colors(child, bag)

def walk_texts(node, bag):
    if not isinstance(node, dict): return
    if node.get('type') == 'TEXT':
        s = node.get('style', {})
        if isinstance(s, dict):
            chars = node.get('characters','')[:80]
            bag.add((s.get('fontFamily'), s.get('fontSize'), s.get('fontWeight'), chars))
    for child in node.get('children', []):
        walk_texts(child, bag)

def deep_print(node, indent=0, max_depth=8):
    if not isinstance(node, dict) or indent > max_depth*2: return
    t = node.get('type','')
    n = node.get('name','')
    chars = node.get('characters','')
    extra = f' -> "{chars[:70]}"' if chars else ''
    style = node.get('style',{}) if isinstance(node.get('style'), dict) else {}
    fs = style.get('fontSize','')
    fw = style.get('fontWeight','')
    ff = style.get('fontFamily','')
    font_info = f' [{ff} {fs}px w{fw}]' if fs else ''
    fills = node.get('fills',[])
    fill_info = ''
    if isinstance(fills, list):
        for f0 in fills:
            if isinstance(f0, dict) and f0.get('type')=='SOLID' and f0.get('visible', True) is not False:
                c = f0.get('color',{})
                if isinstance(c, dict):
                    r,g,b = int(c.get('r',0)*255),int(c.get('g',0)*255),int(c.get('b',0)*255)
                    fill_info = f' #{r:02X}{g:02X}{b:02X}'
                break
    bb = node.get('absoluteBoundingBox',{})
    sz = f' {int(bb.get("width",0))}x{int(bb.get("height",0))}' if bb else ''
    print(' '*indent + f'[{t}] {n}{sz}{extra}{font_info}{fill_info}')
    for child in node.get('children', []):
        deep_print(child, indent+2, max_depth)

# Full color + text palette across all screens
color_bag = set()
text_bag  = set()
for s in screens:
    walk_colors(s, color_bag)
    walk_texts(s, text_bag)

print('=== FULL COLOR PALETTE ===')
for r,g,b,a in sorted(color_bag):
    print(f'  #{r:02X}{g:02X}{b:02X}  rgba({r},{g},{b},{a})')

print('\n=== ALL TEXT STYLES ===')
seen = set()
for (ff, fs, fw, sample) in sorted(text_bag, key=lambda x: (x[0] or '', x[1] or 0)):
    k = (ff, fs, fw)
    if k not in seen and ff:
        seen.add(k)
        print(f'  {ff}  {fs}px  weight:{fw}   e.g: "{sample}"')

# Print key screens
key_screens = ['Splash', 'Onboarding', 'Home', 'AI Meal Scanner', 'Meal Analysis', 'Daily Nutrition', 'AI Chat', 'Profile']
for screen_name in key_screens:
    s = next((x for x in screens if x.get('name','').lower() == screen_name.lower()), None)
    if s:
        print(f'\n{"="*60}\nSCREEN: {screen_name}\n{"="*60}')
        deep_print(s, max_depth=8)
