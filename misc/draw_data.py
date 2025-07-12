import csv
import numpy as np
import matplotlib.pyplot as plt

def set_axes_equal(ax):
  # 设置三维坐标轴比例相等，避免图像扭曲
  limits = np.array([
    ax.get_xlim3d(),
    ax.get_ylim3d(),
    ax.get_zlim3d(),
  ])
  spans = limits[:,1] - limits[:,0]
  centers = np.mean(limits, axis=1)
  radius = 0.5 * max(spans)
  ax.set_xlim3d(centers[0] - radius, centers[0] + radius)
  ax.set_ylim3d(centers[1] - radius, centers[1] + radius)
  ax.set_zlim3d(centers[2] - radius, centers[2] + radius)

def draw_sphere(ax, x0, y0, z0, r):
  # 绘制球体网格
  u = np.linspace(0, 2 * np.pi, 20)
  v = np.linspace(0, np.pi, 20)
  x = r * np.outer(np.cos(u), np.sin(v)) + x0
  y = r * np.outer(np.sin(u), np.sin(v)) + y0
  z = r * np.outer(np.ones_like(u), np.cos(v)) + z0
  ax.plot_surface(x, y, z, color='b', alpha=0.6, linewidth=0, shade=True)

def main(csv_path):
  fig = plt.figure()
  ax = fig.add_subplot(111, projection='3d')

  with open(csv_path, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
      r = float(row['radius'])
      x = float(row['x'])
      y = float(row['y'])
      z = float(row['z'])
      draw_sphere(ax, x, y, z, r)

  set_axes_equal(ax)
  ax.view_init(elev=30, azim=45)
  plt.tight_layout()
  plt.savefig('output.png', dpi=300)
  plt.close()

if __name__ == '__main__':
  import sys
  main(sys.argv[1] if len(sys.argv) > 1 else 'data.csv')
