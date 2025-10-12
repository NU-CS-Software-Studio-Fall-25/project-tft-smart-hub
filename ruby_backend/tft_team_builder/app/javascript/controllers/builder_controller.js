// app/javascript/controllers/builder_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 在 targets 列表中加入新的 'count'
  static targets = ["poolChampion", "lineup", "hiddenField", "count"]

  connect() {
    console.log("Builder controller connected!")
    // 页面加载时就更新一次计数
    this.updateLineupState();
  }

  add(event) {
    const championElement = event.currentTarget;
    const championId = championElement.dataset.id;
    
    if (this.lineupTarget.querySelector(`[data-id='${championId}']`)) {
      alert("阵容中已存在该英雄！");
      return;
    }

    const newChampionInLineup = championElement.cloneNode(true);
    newChampionInLineup.dataset.action = "click->builder#remove";
    this.lineupTarget.appendChild(newChampionInLineup);

    this.updateLineupState();
  }

  remove(event) {
    const championElement = event.currentTarget;
    championElement.remove();
    this.updateLineupState();
  }

  // 我们把所有更新操作都集中到这个新方法里
  updateLineupState() {
    const championElements = this.lineupTarget.children;
    const championNames = Array.from(championElements).map(el => el.dataset.name);

    // 更新隐藏表单域
    this.hiddenFieldTarget.value = championNames.join(',');
    
    // 更新阵容数量显示
    this.countTarget.textContent = championElements.length;
    
    console.log("Current lineup:", this.hiddenFieldTarget.value);
  }
}