<template>
  <div id="main">
    <canvas ref="domRef"></canvas>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import * as THREE from "three";
import { TrackballControls } from "three/examples/jsm/controls/TrackballControls";
import { CSS2DRenderer } from "three/examples/jsm/renderers/CSS2DRenderer";
import {
  addBVHExtension,
  initThree,
  animate,
  getPointNDCPosition,
} from "../utils";

const domRef = ref<HTMLCanvasElement>();
let scene: THREE.Scene;
let camera: THREE.OrthographicCamera;
let renderer: THREE.WebGLRenderer;
let controller: TrackballControls;
let labelRenderer: CSS2DRenderer;

// -----------------------------初始化------------------------------
addBVHExtension();
onMounted(() => {
  init();
  animate({
    camera,
    controller,
    labelRenderer,
    renderer,
    scene,
  });
});
/** 场景初始化 */
async function init() {
  const initReturn = initThree({
    width: innerWidth,
    height: innerHeight,
    canvas: domRef.value!,
  });
  camera = initReturn.camera;
  controller = initReturn.controller;
  labelRenderer = initReturn.labelRenderer;
  renderer = initReturn.renderer;
  scene = initReturn.scene;
}

// -----------------------添加线，射线检测---------------------------
const lineList: THREE.Line[] = [];
const raycaster = new THREE.Raycaster();
raycaster.firstHitOnly = true;
onMounted(() => {
  addLine();
  labelRenderer.domElement.addEventListener("pointermove", onPointerMove);
});
// 添加线
function addLine() {
  const material = new THREE.LineBasicMaterial({
    color: 0x0000ff,
  });
  const points = [];
  points.push(new THREE.Vector3(-10, 0, 0));
  points.push(new THREE.Vector3(0, 10, 0));
  points.push(new THREE.Vector3(10, 0, 0));
  points.push(new THREE.Vector3(15, 15, 15));
  points.push(new THREE.Vector3(-10, 10, 10));
  points.push(new THREE.Vector3(6, 6, 6));

  const geometry = new THREE.BufferGeometry().setFromPoints(points.slice(0, 3));
  geometry.computeBoundsTree();
  const line = new THREE.Line(geometry, material);
  scene.add(line);
  lineList.push(line);

  const geometry1 = new THREE.BufferGeometry().setFromPoints(
    points.slice(3, 6)
  );
  geometry1.computeBoundsTree();
  const line1 = new THREE.Line(geometry1, material.clone());
  scene.add(line1);
  lineList.push(line1);
}
/** 射线检测线 */
function onPointerMove(event: PointerEvent) {
  const rect = new THREE.Vector2();
  renderer.getSize(rect);
  const pointPos = getPointNDCPosition(event, rect.x, rect.y);
  raycaster.setFromCamera(pointPos, camera);
  const intersects = raycaster.intersectObjects(scene.children);
  if (intersects.length > 0 && intersects[0].object instanceof THREE.Line) {
    (intersects[0].object.material as THREE.LineBasicMaterial).color.set(
      0xffffff
    );
  }
  lineList.forEach((item) => {
    if (!intersects[0] || intersects[0].object !== item) {
      (item.material as THREE.LineBasicMaterial).color.set(0x0000ff);
    }
  });
}

// ---------------------------添加面，设置相机视角--------------------
onMounted(() => {
  const plane = createPlan();
  const outline = createOutline(plane.geometry);
  outline.position.set(25, -250, -250);
  const quaternion = new THREE.Quaternion().setFromUnitVectors(
    new THREE.Vector3(0, 0, 1),
    new THREE.Vector3(-0.856, 1, 0.353)
  );
  outline.applyQuaternion(quaternion);
  scene.add(outline);
  setView(outline);
});
function createPlan() {
  const geometry = new THREE.PlaneGeometry(50, 50);
  const material = new THREE.MeshBasicMaterial({
    color: 0xffff00,
    side: THREE.DoubleSide,
  });
  const plane = new THREE.Mesh(geometry, material);
  plane.position.set(25, -250, -250);
  const quaternion = new THREE.Quaternion().setFromUnitVectors(
    new THREE.Vector3(0, 0, 1),
    new THREE.Vector3(-0.856, 1, 0.353)
  );
  plane.applyQuaternion(quaternion);
  return plane;
}

function createOutline(geometry: THREE.BufferGeometry) {
  const edges = new THREE.EdgesGeometry(geometry);
  const outline = new THREE.LineSegments(
    edges,
    new THREE.LineBasicMaterial({ color: 0xffffff })
  );
  return outline;
}

function setView(object: THREE.Object3D) {
  const rect = new THREE.Vector2();
  renderer.getSize(rect);
  const box = new THREE.Box3().setFromObject(object);
  const size = new THREE.Vector3();
  box.getSize(size);
  const meshFrustumSize = Math.max(size.x, size.y, size.z);
  const widthZoom = rect.x / meshFrustumSize;
  const heightZoom = rect.y / meshFrustumSize;
  if (widthZoom >= heightZoom) {
    camera.zoom = heightZoom;
  } else {
    camera.zoom = widthZoom;
  }
  const v3 = new THREE.Vector3();
  box.getCenter(v3);
  const pos = v3
    .clone()
    .addScaledVector(
      new THREE.Vector3(-0.856, 1, 0.353).normalize(),
      meshFrustumSize
    );
  camera.position.copy(pos);
  camera.lookAt(v3);
  controller.target = v3;
  controller.update();
  camera.updateProjectionMatrix();
}
</script>

<style>
#main {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
}
canvas {
  width: 100%;
  height: 100%;
}
</style>
