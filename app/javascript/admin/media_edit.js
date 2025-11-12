// 画像編集機能
document.addEventListener('DOMContentLoaded', function() {
  console.log('=== Media Edit DOMContentLoaded ===');
  console.log('window.Cropper at DOMContentLoaded:', typeof window.Cropper);
  
  const currentImage = document.getElementById('current-image');
  const editCanvas = document.getElementById('edit-canvas');
  const previewImage = document.getElementById('preview-image');
  const applyBtn = document.getElementById('apply-btn');
  
  let ctx = null;
  let originalImageData = null;
  let currentImageData = null;
  let cropData = null;
  
  if (editCanvas && currentImage) {
    ctx = editCanvas.getContext('2d', { willReadFrequently: true });
    loadOriginalImage();
  }
  
  function loadOriginalImage() {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = function() {
      // 元画像のサイズを保持
      const originalWidth = img.width;
      const originalHeight = img.height;
      
      // 680px幅に合わせて表示サイズを計算（縦横比維持）
      let displayWidth = originalWidth;
      let displayHeight = originalHeight;
      
      if (displayWidth > 680) {
        const scale = 680 / displayWidth;
        displayWidth = 680;
        displayHeight = originalHeight * scale;
      }
      
      // 表示用画像のサイズを設定
      currentImage.style.width = displayWidth + 'px';
      currentImage.style.height = displayHeight + 'px';
      
      // キャンバスは元のサイズで設定
      editCanvas.width = originalWidth;
      editCanvas.height = originalHeight;
      ctx.drawImage(img, 0, 0);
      originalImageData = ctx.getImageData(0, 0, originalWidth, originalHeight);
      currentImageData = ctx.getImageData(0, 0, originalWidth, originalHeight);
    };
    img.src = currentImage.src;
  }
  
  // リサイズ機能
  window.resizeImage = function(scale) {
    if (!originalImageData) return;
    
    const newWidth = Math.floor(originalImageData.width * scale);
    const newHeight = Math.floor(originalImageData.height * scale);
    
    // 新しいキャンバスを作成
    const tempCanvas = document.createElement('canvas');
    const tempCtx = tempCanvas.getContext('2d');
    tempCanvas.width = newWidth;
    tempCanvas.height = newHeight;
    
    // 元の画像を新しいサイズで描画
    const img = new Image();
    img.onload = function() {
      tempCtx.drawImage(img, 0, 0, newWidth, newHeight);
      
      // プレビューを更新（表示サイズも調整）
      updatePreview(tempCanvas.toDataURL(), newWidth, newHeight);
      currentImageData = tempCtx.getImageData(0, 0, newWidth, newHeight);
      enableApplyButton();
    };
    img.src = currentImage.src;
  };
  
  // 正方形クロップ
  window.cropToSquare = function() {
    if (!originalImageData) return;
    
    const size = Math.min(originalImageData.width, originalImageData.height);
    const x = (originalImageData.width - size) / 2;
    const y = (originalImageData.height - size) / 2;
    
    const tempCanvas = document.createElement('canvas');
    const tempCtx = tempCanvas.getContext('2d');
    tempCanvas.width = size;
    tempCanvas.height = size;
    
    const img = new Image();
    img.onload = function() {
      tempCtx.drawImage(img, x, y, size, size, 0, 0, size, size);
      updatePreview(tempCanvas.toDataURL(), size, size);
      currentImageData = tempCtx.getImageData(0, 0, size, size);
      enableApplyButton();
    };
    img.src = currentImage.src;
  };
  
  // 円形クロップ
  window.cropToCircle = function() {
    if (!originalImageData) return;
    
    const size = Math.min(originalImageData.width, originalImageData.height);
    const radius = size / 2;
    
    const tempCanvas = document.createElement('canvas');
    const tempCtx = tempCanvas.getContext('2d');
    tempCanvas.width = size;
    tempCanvas.height = size;
    
    const img = new Image();
    img.onload = function() {
      // 円形のクリッピングパスを作成
      tempCtx.beginPath();
      tempCtx.arc(radius, radius, radius, 0, 2 * Math.PI);
      tempCtx.clip();
      
      // 画像を描画
      const x = (originalImageData.width - size) / 2;
      const y = (originalImageData.height - size) / 2;
      tempCtx.drawImage(img, x, y, size, size, 0, 0, size, size);
      
      updatePreview(tempCanvas.toDataURL(), size, size);
      currentImageData = tempCtx.getImageData(0, 0, size, size);
      enableApplyButton();
    };
    img.src = currentImage.src;
  };
  
  // 画像圧縮
  window.compressImage = function(quality) {
    if (!originalImageData) return;
    
    const tempCanvas = document.createElement('canvas');
    const tempCtx = tempCanvas.getContext('2d');
    tempCanvas.width = originalImageData.width;
    tempCanvas.height = originalImageData.height;
    
    const img = new Image();
    img.onload = function() {
      tempCtx.drawImage(img, 0, 0);
      const compressed = tempCanvas.toDataURL('image/jpeg', quality);
      updatePreview(compressed, originalImageData.width, originalImageData.height);
      currentImageData = tempCtx.getImageData(0, 0, originalImageData.width, originalImageData.height);
      enableApplyButton();
    };
    img.src = currentImage.src;
  };
  
  // プレビュー更新
  function updatePreview(dataURL, actualWidth, actualHeight) {
    previewImage.src = dataURL;
    previewImage.style.display = 'block';
    
    // 680px幅に合わせて表示サイズを計算（縦横比維持）
    if (actualWidth && actualHeight) {
      let displayWidth = actualWidth;
      let displayHeight = actualHeight;
      
      if (displayWidth > 680) {
        const scale = 680 / displayWidth;
        displayWidth = 680;
        displayHeight = actualHeight * scale;
      }
      
      previewImage.style.width = displayWidth + 'px';
      previewImage.style.height = displayHeight + 'px';
    }
  }
  
  // 適用ボタンを有効化
  function enableApplyButton() {
    applyBtn.disabled = false;
  }
  
  // 変更を適用
  window.applyChanges = function() {
    if (!previewImage.src) return;
    
    // プレビュー画像を現在の画像に設定
    currentImage.src = previewImage.src;
    
    // サーバーに変更を送信（実装が必要）
    uploadEditedImage(previewImage.src);
  };
  
  // リセット
  window.resetChanges = function() {
    previewImage.style.display = 'none';
    document.getElementById('crop-container').style.display = 'none';
    document.getElementById('crop-actions').style.display = 'none';
    applyBtn.disabled = true;
    currentImageData = originalImageData;
    cropData = null;
  };
  
  // Cropper.jsのインスタンス
  let cropper = null;

  // 手動トリミング開始
  window.enableManualCrop = function() {
    console.log('手動トリミング開始');
    
    if (!currentImage || !currentImage.src) {
      console.error('画像がありません:', currentImage);
      alert('画像が選択されていません。先に画像を読み込んでください。');
      return;
    }
    
    const cropContainer = document.getElementById('crop-container');
    const cropImage = document.getElementById('crop-image');
    const cropActions = document.getElementById('crop-actions');
    
    console.log('要素チェック:', { cropContainer, cropImage, cropActions });
    
    if (!cropContainer || !cropImage || !cropActions) {
      console.error('必要な要素が見つかりません');
      alert('トリミング機能の初期化に失敗しました。ページを再読み込みしてください。');
      return;
    }
    
    // 直接Cropper.jsを読み込み
    console.log('Cropper.jsの読み込みを開始...');
    loadCropperDirectly();
  };
  
  // Cropper UIの初期化を分離
  function initializeCropperUI() {
    const cropContainer = document.getElementById('crop-container');
    const cropImage = document.getElementById('crop-image');
    const cropActions = document.getElementById('crop-actions');
    
    // プレビュー画像を非表示
    previewImage.style.display = 'none';
    
    // 既存のCropperインスタンスがあれば破棄
    if (cropper) {
      cropper.destroy();
      cropper = null;
    }
    
    // クロップ用画像を設定
    cropImage.src = currentImage.src;
    cropImage.style.maxWidth = '680px';
    cropImage.style.width = 'auto';
    cropImage.style.height = 'auto';
    
    // クロップコンテナを表示
    cropContainer.style.display = 'block';
    cropActions.style.display = 'flex';
    
    console.log('クロップコンテナを表示しました');
    
    // 画像読み込み後にCropper.jsを初期化
    cropImage.onload = function() {
      console.log('クロップ画像が読み込まれました');
      console.log('Cropper.js確認:', typeof window.Cropper);
      
      if (typeof window.Cropper !== 'undefined' && typeof window.Cropper === 'function') {
        console.log('Cropper.jsインスタンス作成開始');
        
        try {
          cropper = new window.Cropper(cropImage, {
            aspectRatio: NaN, // 自由なアスペクト比
            viewMode: 1, // 画像の境界内でクロップ
            dragMode: 'move', // ドラッグで移動
            autoCropArea: 0.5, // 初期クロップエリアのサイズ（50%）
            restore: false, // リサイズ時の復元を無効
            guides: true, // ガイドラインを表示
            center: true, // 中央線を表示
            highlight: true, // ハイライト効果
            cropBoxMovable: true, // クロップボックスの移動を許可
            cropBoxResizable: true, // クロップボックスのリサイズを許可
            toggleDragModeOnDblclick: false, // ダブルクリックでのモード切替を無効
            responsive: true, // レスポンシブ対応
            background: false, // 背景の格子模様を非表示
            ready: function() {
              console.log('Cropper.jsの準備完了（readyコールバック） - トリミング枠線が表示されました！');
            }
          });
          
          console.log('Cropper.jsが初期化されました:', cropper);
          
          // Cropperが正常に動作することを確認（readyイベントの代替）
          // Cropper.js v1.6.1では、初期化後すぐに利用可能
          setTimeout(function() {
            console.log('Cropper.jsの準備完了 - トリミング枠線が表示されました！');
            console.log('Cropper操作可能:', cropper && typeof cropper.getCroppedCanvas === 'function');
          }, 100);
          
        } catch (error) {
          console.error('Cropper.jsの初期化エラー:', error);
          alert('画像トリミング機能の初期化に失敗しました: ' + error.message);
        }
      } else {
        console.error('Cropper.jsが利用できません');
        alert('Cropper.jsが読み込まれていません。ページを再読み込みしてください。');
      }
    };
    
    // 画像が既に読み込まれている場合の処理
    if (cropImage.complete) {
      cropImage.onload();
    }
  }
  

  
  // トリミング実行
  window.applyCrop = function() {
    console.log('トリミング実行開始');
    
    if (!cropper) {
      console.error('Cropperインスタンスが見つかりません');
      return;
    }
    
    // Cropper.jsからトリミングされた画像データを取得
    const canvas = cropper.getCroppedCanvas({
      maxWidth: 2048,
      maxHeight: 2048,
      fillColor: '#fff',
      imageSmoothingEnabled: true,
      imageSmoothingQuality: 'high'
    });
    
    if (!canvas) {
      console.error('キャンバスが作成できませんでした');
      return;
    }
    
    // プレビューを更新
    const dataURL = canvas.toDataURL('image/jpeg', 0.9);
    updatePreview(dataURL, canvas.width, canvas.height);
    
    // 現在の画像データを更新
    const ctx = canvas.getContext('2d');
    currentImageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    
    // 適用ボタンを有効化
    enableApplyButton();
    
    // Cropperを破棄してUIを非表示
    cropper.destroy();
    cropper = null;
    
    document.getElementById('crop-container').style.display = 'none';
    document.getElementById('crop-actions').style.display = 'none';
    
    console.log('トリミング実行完了');
  };
  
    // トリミングキャンセル
  window.cancelCrop = function() {
    console.log('トリミングキャンセル');
    
    // Cropperインスタンスを破棄
    if (cropper) {
      cropper.destroy();
      cropper = null;
    }
    
    // UIを非表示
    document.getElementById('crop-container').style.display = 'none';
    document.getElementById('crop-actions').style.display = 'none';
    
    // プレビュー画像を再表示
    previewImage.style.display = previewImage.src ? 'block' : 'none';
  };
  
  // 編集された画像をサーバーにアップロード
  function uploadEditedImage(dataURL) {
    // Base64をBlobに変換
    fetch(dataURL)
      .then(res => res.blob())
      .then(blob => {
        const formData = new FormData();
        // Blobの実際の形式に基づいてファイル名を決定
        const fileExtension = blob.type === 'image/png' ? 'png' : 'jpg';
        formData.append('medium[file]', blob, `edited_image.${fileExtension}`);
        
        // 既存のフォーム値も含める
        const titleField = document.querySelector('input[name="medium[title]"]');
        const descriptionField = document.querySelector('textarea[name="medium[description]"]');
        const altTextField = document.querySelector('input[name="medium[alt_text]"]');
        
        if (titleField) formData.append('medium[title]', titleField.value);
        if (descriptionField) formData.append('medium[description]', descriptionField.value);
        if (altTextField) formData.append('medium[alt_text]', altTextField.value);
        
        const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
        
        // /admin/media/3/edit から /admin/media/3 に変換
        const updateUrl = window.location.pathname.replace('/edit', '');
        
        fetch(updateUrl, {
          method: 'PATCH',
          headers: {
            'X-CSRF-Token': token,
            'Accept': 'application/json'
          },
          body: formData
        })
        .then(response => response.json())
        .then(data => {
          if (data.status === 'success') {
            alert('画像の編集が保存されました！');
            window.location.reload();
          } else {
            alert('保存に失敗しました: ' + (data.message || '不明なエラー'));
          }
        })
        .catch(error => {
          console.error('Error:', error);
          alert('保存中にエラーが発生しました。');
        });
      });
  }
  
  // 代替案: 直接Cropper.jsを読み込む関数
  function loadCropperDirectly() {
    console.log('代替案でCropper.jsを読み込み開始');
    
    return new Promise((resolve, reject) => {
      if (typeof window.Cropper !== 'undefined') {
        console.log('Cropper.jsは既に読み込まれています');
        resolve(window.Cropper);
        return;
      }

      // CSS読み込み
      const cssLink = document.createElement('link');
      cssLink.rel = 'stylesheet';
      cssLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.css';
      document.head.appendChild(cssLink);
      
      // JavaScript読み込み
      const script = document.createElement('script');
      script.src = 'https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.js';
      script.onload = function() {
        console.log('=== Cropper.js CDN読み込み完了（代替案） ===');
        console.log('window.Cropper:', typeof window.Cropper);
        initializeCropperUI();
      };
      script.onerror = function() {
        console.error('Cropper.jsの読み込みに失敗（代替案）');
        alert('画像トリミング機能の読み込みに失敗しました。インターネット接続を確認してください。');
      };
      document.head.appendChild(script);
    });
  }
});

// ページ読み込み完了後にもCropper.jsの状態を確認
window.addEventListener('load', function() {
  console.log('=== Window Load完了時のCropper.js確認 ===');
  console.log('window.Cropper:', typeof window.Cropper);
  
  // デバッグ用: 手動でCropper.jsの状態を確認する関数を追加
  window.checkCropper = function() {
    console.log('=== 手動Cropper.js確認 ===');
    console.log('window.Cropper:', typeof window.Cropper);
    console.log('Cropper function:', window.Cropper);
    return typeof window.Cropper;
  };
});