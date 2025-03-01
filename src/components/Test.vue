<template>
  <div id="main">
    <canvas ref="domRef"></canvas>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import * as THREE from "three";
import { CSS2DRenderer } from "three/examples/jsm/renderers/CSS2DRenderer";
import { initThree, animate, updateCamera, addBVHExtension } from "@/utils/index.ts";
import commonVertex from "../glsl/vert/commonVertex.glsl";
import commonFragment from "../glsl/frag/commonFragment.glsl";
import { OrbitControls } from "three/examples/jsm/Addons";

const domRef = ref<HTMLCanvasElement>();
let scene: THREE.Scene;
let camera: THREE.OrthographicCamera;
let renderer: THREE.WebGLRenderer;
let controller: OrbitControls;
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
function init() {
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

// 创建几何体
onMounted(() => {
  const box = createGeometry();
  scene.add(box);
  updateCamera(camera, controller, [box], renderer);
  controller.autoRotate = true;
});
function createGeometry() {
  const geometry = new THREE.BoxGeometry(100, 100, 100);
  const material = new THREE.ShaderMaterial({
    vertexShader: commonVertex,
    fragmentShader: commonFragment,
    uniforms: {
      center: {
        value: new THREE.Vector3(),
      },
      xy: {
        value: new THREE.Vector2(),
      },
    },
  });
  const box = new THREE.Mesh(geometry, material);
  const box3 = new THREE.Box3().setFromObject(box);
  material.uniforms.center.value = box3.getCenter(new THREE.Vector3());
  material.uniforms.xy.value = new THREE.Vector2(box3.max.x - box3.min.x, box3.max.y - box3.min.y);
  return new THREE.Mesh(geometry, material);
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
