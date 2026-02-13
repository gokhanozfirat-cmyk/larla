p = r'c:\Users\Lenovo\Desktop\Dualarla\lib\screens\journeys_page.dart'
with open(p, 'r', encoding='utf-8') as f:
    s = f.read()
open_count = s.count('{')
close_count = s.count('}')
print(f"open:{open_count} close:{close_count}")
