// メディア選択機能
class MediaSelector {
  constructor() {
    this.callback = null;
  }
  
  // メディア選択ダイアログを開く
  open(callback, options = {}) {
    this.callback = callback;
    const { type = 'all', title = 'メディアを選択' } = options;
    
    // オーバーレイを作成
    const overlay = document.createElement('div');
    overlay.id = 'media-selector-overlay';
    overlay.innerHTML = `
      <div class="media-selector-loading">
        <div class="spinner"></div>
        <p>読み込み中...</p>
      </div>
    `;
    
    document.body.appendChild(overlay);
    
    // Ajax でメディア選択画面を読み込み
    fetch(`/admin/media/select?type=${type}`, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/html'
      }
    })
    .then(response => response.text())
    .then(html => {
      overlay.innerHTML = html;
      this.initializeEventHandlers();
    })
    .catch(error => {
      console.error('メディア選択画面の読み込みに失敗:', error);
      overlay.innerHTML = `
        <div class="media-selector-modal">
          <div class="media-selector-header">
            <h3>エラー</h3>
            <button class="close-modal" onclick="closeMediaSelector()">×</button>
          </div>
          <div style="padding: 20px; text-align: center;">
            <p>メディア選択画面の読み込みに失敗しました。</p>
            <button class="btn btn-primary" onclick="closeMediaSelector()">閉じる</button>
          </div>
        </div>
      `;
    });
  }
  
  // イベントハンドラーの初期化
  initializeEventHandlers() {
    // グローバルコールバック関数を設定
    window.mediaSelectCallback = (id, title, url) => {
      if (this.callback) {
        this.callback({ id, title, url });
      }
    };
    
    // ESC キーで閉じる
    document.addEventListener('keydown', this.handleKeydown.bind(this));
    
    // オーバーレイクリックで閉じる
    const overlay = document.getElementById('media-selector-overlay');
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay) {
        this.close();
      }
    });
  }
  
  // キーボードイベントハンドラー
  handleKeydown(e) {
    if (e.key === 'Escape') {
      this.close();
    }
  }
  
  // ダイアログを閉じる
  close() {
    const overlay = document.getElementById('media-selector-overlay');
    if (overlay) {
      overlay.remove();
    }
    
    // イベントリスナーを削除
    document.removeEventListener('keydown', this.handleKeydown.bind(this));
    
    // グローバルコールバックをクリア
    window.mediaSelectCallback = null;
    this.callback = null;
  }
}

// グローバル関数として公開
window.closeMediaSelector = function() {
  const mediaSelector = new MediaSelector();
  mediaSelector.close();
};

// インスタンスを作成してグローバルに公開
window.mediaSelector = new MediaSelector();

// フォーム要素にメディア選択機能を追加するヘルパー
window.addMediaSelector = function(inputElement, options = {}) {
  const wrapper = document.createElement('div');
  wrapper.className = 'media-selector-wrapper';
  
  // 入力フィールドをラップ
  inputElement.parentNode.insertBefore(wrapper, inputElement);
  wrapper.appendChild(inputElement);
  
  // 選択ボタンを追加
  const selectButton = document.createElement('button');
  selectButton.type = 'button';
  selectButton.className = 'btn btn-secondary media-select-btn';
  selectButton.textContent = 'メディアから選択';
  selectButton.onclick = function() {
    window.mediaSelector.open((media) => {
      inputElement.value = media.url;
      
      // プレビュー表示があれば更新
      const preview = wrapper.querySelector('.media-preview');
      if (preview && media.url.match(/\.(jpg|jpeg|png|gif|webp)$/i)) {
        preview.src = media.url;
        preview.style.display = 'block';
      }
      
      // カスタムコールバックがあれば実行
      if (options.onSelect) {
        options.onSelect(media);
      }
    }, options);
  };
  
  wrapper.appendChild(selectButton);
  
  // プレビュー要素を追加（画像の場合）
  if (options.showPreview !== false) {
    const preview = document.createElement('img');
    preview.className = 'media-preview';
    preview.style.display = 'none';
    preview.style.maxWidth = '200px';
    preview.style.maxHeight = '200px';
    preview.style.marginTop = '10px';
    preview.style.borderRadius = '4px';
    wrapper.appendChild(preview);
    
    // 既存の値がある場合はプレビューを表示
    if (inputElement.value && inputElement.value.match(/\.(jpg|jpeg|png|gif|webp)$/i)) {
      preview.src = inputElement.value;
      preview.style.display = 'block';
    }
  }
};

console.log('Media Selector loaded');