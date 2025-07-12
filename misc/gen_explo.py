import math
from typing import List, Tuple
import csv

def export_spheres_to_csv(spheres, filename='spheres.csv'):
  with open(filename, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['radius', 'x', 'y', 'z'])  # 表头
    for radius, (x, y, z) in spheres:
      writer.writerow([radius, x, y, z])

Vec3 = Tuple[float, float, float]
Sphere = Tuple[float, Vec3]

def distance(a: Vec3, b: Vec3) -> float:
  return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))

def generate_filled_spheres(
  max_radius: float = 4.0,
  fill_radius: float = 4,
  explosion_radius: float = 16.0,
  target_cover_radius: float = 8.0,
  spacing_factor: float = 0.9
) -> List[Sphere]:
  """填充爆炸球体区域，返回每个子爆点的（半径, 中心坐标）"""
  spheres: List[Sphere] = []
  step = spacing_factor * 2 * max_radius
  limit = explosion_radius + max_radius
  r2 = max_radius ** 2

  # 尝试以较密的方式填充 max_radius 的球体
  for x in frange(-limit, limit, step):
    for y in frange(-limit, limit, step):
      for z in frange(-limit, limit, step):
        d = math.sqrt(x**2 + y**2 + z**2)
        if d + max_radius <= explosion_radius:
          spheres.append((max_radius, (x, y, z)))

  # 查找 target_cover_radius 内未覆盖区域，补充 fill_radius 球体
  filled_points = [center for _, center in spheres]
  check_step = fill_radius * spacing_factor
  for x in frange(-target_cover_radius, target_cover_radius, check_step):
    for y in frange(-target_cover_radius, target_cover_radius, check_step):
      for z in frange(-target_cover_radius, target_cover_radius, check_step):
        p = (x, y, z)
        if math.sqrt(x**2 + y**2 + z**2) > target_cover_radius:
          continue
        if all(distance(p, c) > max_radius for c in filled_points):
          spheres.append((fill_radius, p))
          filled_points.append(p)

  return spheres

def frange(start: float, stop: float, step: float):
  while start <= stop:
    yield start
    start += step

spheres = generate_filled_spheres()
#print(spheres[:5])
print(len(spheres))
export_spheres_to_csv(spheres)

