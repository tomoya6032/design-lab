// WYSIWYG Editor functionality
console.log('rich_editor.js loaded');

// DOMContentLoadedとwindow.onloadの両方で試行
function initializeRichEditor() {
  console.log('Attempting to initialize rich editor');
  
  const toolbar = document.querySelector('.editor-toolbar');
  const editor = document.querySelector('.editor-content');
  const hiddenField = document.querySelector('#content_json_hidden');
  
  console.log('Elements found:', { toolbar, editor, hiddenField });
  
  if (!toolbar || !editor || !hiddenField) {
    console.error('Required elements not found for rich editor');
    return false;
  }
  
  // 既に初期化済みかチェック
  if (toolbar.dataset.initialized === 'true') {
    console.log('Rich editor already initialized');
    return true;
  }
  
  // 初期化フラグを設定
  toolbar.dataset.initialized = 'true';
  
  console.log('Initializing rich editor...');
  setupRichEditor(toolbar, editor, hiddenField);
  return true;
}

document.addEventListener('DOMContentLoaded', function() {
  console.log('rich_editor.js DOM loaded');
  setTimeout(initializeRichEditor, 100); // 少し遅延させて初期化
});

window.addEventListener('load', function() {
  console.log('rich_editor.js window loaded');
  initializeRichEditor();
});

function setupRichEditor(toolbar, editor, hiddenField) {
  console.log('Setting up rich editor with elements:', { toolbar, editor, hiddenField });
  
  // 画像挿入機能の変数
  let imageModalInitialized = false;
  let selectedFiles = [];
  let currentRange = null;
  
  if (!toolbar || !editor || !hiddenField) {
    console.error('Required elements not found for rich editor');
    return;
  }
  
  // エディターの初期設定
  editor.style.minHeight = '300px';
  editor.style.padding = '16px';
  editor.style.border = '1px solid #ced4da';
  editor.style.borderRadius = '4px';
  editor.style.outline = 'none';
  
  // ローカルストレージのキー（記事IDベース）
  const currentPath = window.location.pathname;
  const articleId = currentPath.split('/').pop();
  const storageKey = currentPath.includes('/new') ? 'article_content_draft_new' : `article_content_draft_${articleId}`;
  
  // 新規作成時は常に空の状態で開始
  if (currentPath.includes('/new')) {
    // 過去の下書きデータをすべてクリア
    const keysToRemove = [];
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && key.startsWith('article_content_draft')) {
        keysToRemove.push(key);
      }
    }
    keysToRemove.forEach(key => localStorage.removeItem(key));
    
    // エディターを空にする
    editor.innerHTML = '';
    updateHiddenField();
  } else if (currentPath.includes('/edit')) {
    // 編集時のみローカルストレージから復元を試行
    const savedContent = localStorage.getItem(storageKey);
    if (savedContent && savedContent !== '' && editor.innerHTML.trim() === '') {
      editor.innerHTML = savedContent;
      updateHiddenField();
    }
  }

  
  // ツールバーボタンのクリック処理
  toolbar.addEventListener('click', function(e) {
    e.preventDefault();
    const button = e.target.closest('.toolbar-btn');
    if (!button) return;
    
    const command = button.dataset.command;
    editor.focus();
    
    switch(command) {
      case 'bold':
        document.execCommand('bold', false, null);
        updateButtonState(button, document.queryCommandState('bold'));
        break;
      case 'underline':
        document.execCommand('underline', false, null);
        updateButtonState(button, document.queryCommandState('underline'));
        break;
      case 'h2':
        toggleHeading('h2', button);
        break;
      case 'h3':
        toggleHeading('h3', button);
        break;
      case 'h4':
        toggleHeading('h4', button);
        break;
      case 'yellow-marker':
        toggleMarker('yellow', button);
        break;
      case 'pink-marker':
        toggleMarker('pink', button);
        break;
      case 'removeFormat':
        document.execCommand('removeFormat', false, null);
        removeCustomMarkers();
        updateAllButtonStates();
        break;
      case 'selectAll':
        document.execCommand('selectAll', false, null);
        break;
      case 'link':
        handleLinkInsertion();
        break;
      case 'sns-link':
        handleSnsLinkInsertion();
        break;
      case 'image':
        console.log('Image button clicked');
        handleImageInsertion();
        break;
    }
    
    updateHiddenField();
    saveToLocalStorage();
  });
  
  // ボタン状態の更新
  function updateButtonState(button, isActive) {
    if (isActive) {
      button.classList.add('active');
    } else {
      button.classList.remove('active');
    }
  }
  
  // 全ボタン状態の更新
  function updateAllButtonStates() {
    const buttons = toolbar.querySelectorAll('.toolbar-btn');
    buttons.forEach(button => {
      const command = button.dataset.command;
      switch(command) {
        case 'bold':
          updateButtonState(button, document.queryCommandState('bold'));
          break;
        case 'underline':
          updateButtonState(button, document.queryCommandState('underline'));
          break;
      }
    });
  }
  
  // 見出しのトグル
  function toggleHeading(tagName, button) {
    const selection = window.getSelection();
    if (selection.rangeCount > 0) {
      const element = selection.anchorNode.parentElement;
      if (element.tagName && element.tagName.toLowerCase() === tagName) {
        // 既に見出しタグの場合は解除
        document.execCommand('formatBlock', false, 'p');
        updateButtonState(button, false);
      } else {
        // 見出しタグを適用
        document.execCommand('formatBlock', false, tagName);
        updateButtonState(button, true);
      }
    }
  }
  
  // マーカーのトグル機能
  function toggleMarker(color, button) {
    const selection = window.getSelection();
    if (selection.rangeCount > 0) {
      const range = selection.getRangeAt(0);
      const selectedText = range.toString();
      
      // 選択範囲内のマーカーをチェック
      const parent = range.commonAncestorContainer.parentElement;
      if (parent && parent.classList.contains(`marker-${color}`)) {
        // 既存のマーカーを削除
        const textNode = document.createTextNode(parent.textContent);
        parent.parentNode.replaceChild(textNode, parent);
        updateButtonState(button, false);
      } else if (selectedText) {
        // 新しいマーカーを適用
        const span = document.createElement('span');
        span.className = `marker-${color}`;
        span.style.backgroundColor = color === 'yellow' ? '#fff3cd' : '#f8d7da';
        span.style.padding = '2px 4px';
        
        try {
          range.deleteContents();
          range.insertNode(span);
          span.textContent = selectedText;
          updateButtonState(button, true);
          
          // 選択をクリア
          selection.removeAllRanges();
        } catch (e) {
          console.error('Marker application failed:', e);
        }
      }
    }
  }
  
  // カスタムマーカーの削除
  function removeCustomMarkers() {
    const markers = editor.querySelectorAll('.marker-yellow, .marker-pink');
    markers.forEach(marker => {
      const textNode = document.createTextNode(marker.textContent);
      marker.parentNode.replaceChild(textNode, marker);
    });
  }
  
  // エディターの内容が変更されたときにhiddenフィールドを更新
  editor.addEventListener('input', function() {
    updateHiddenField();
    saveToLocalStorage();
  });
  
  editor.addEventListener('paste', function() {
    setTimeout(function() {
      updateHiddenField();
      saveToLocalStorage();
    }, 100);
  });
  
  // 選択範囲変更時にボタン状態を更新
  editor.addEventListener('selectionchange', updateAllButtonStates);
  document.addEventListener('selectionchange', function() {
    if (document.activeElement === editor) {
      updateAllButtonStates();
    }
  });
  
  function updateHiddenField() {
    hiddenField.value = editor.innerHTML;
  }
  
  function saveToLocalStorage() {
    if (currentPath.includes('/new')) {
      localStorage.setItem(storageKey, editor.innerHTML);
    }
  }
  
  // フォーム送信時にhiddenフィールドを更新し、ローカルストレージをクリア
  const form = editor.closest('form');
  if (form) {
    form.addEventListener('submit', function(e) {
      updateHiddenField();
      // 成功時にのみローカルストレージをクリア（実際のサーバーレスポンスで判断）
      setTimeout(function() {
        if (currentPath.includes('/new')) {
          localStorage.removeItem(storageKey);
        }
      }, 1000);
    });
  }

  // 画像挿入機能
  function handleImageInsertion() {
    console.log('handleImageInsertion called');
    
    // モーダルを初期化（初回のみ）
    initializeImageModal();
    
    const modal = document.querySelector('.image-modal');
    console.log('Modal element:', modal);
    
    if (!modal) {
      console.error('Image modal not found in DOM');
      alert('画像挿入モーダルが見つかりません。ページを再読み込みしてください。');
      return;
    }
    
    // 現在の選択範囲を保存
    const selection = window.getSelection();
    if (selection.rangeCount > 0) {
      currentRange = selection.getRangeAt(0).cloneRange();
    }
    
    // モーダルを表示
    modal.style.display = 'block';
    console.log('Image modal displayed, style:', modal.style.display);
  }
  
  // 画像アップロードと挿入
  function uploadAndInsertImages(files, range) {
    const formData = new FormData();
    files.forEach((file, index) => {
      formData.append(`images[${index}]`, file);
    });
    
    // CSRFトークンを追加
    formData.append('authenticity_token', document.querySelector('meta[name="csrf-token"]').content);
    
    fetch('/admin/articles/upload_images', {
      method: 'POST',
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.success && data.image_urls) {
        insertImagesIntoEditor(data.image_urls, range);
      } else {
        alert('画像のアップロードに失敗しました。');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('画像のアップロードでエラーが発生しました。');
    });
  }
  
  // エディターに画像を挿入
  function insertImagesIntoEditor(imageUrls, range) {
    if (!range) return;
    
    let imageHtml = '';
    
    // 2枚ずつ横並びで配置
    for (let i = 0; i < imageUrls.length; i += 2) {
      imageHtml += '<div class="image-row">';
      
      // 1枚目
      imageHtml += `<div class="image-item"><img src="${imageUrls[i]}" alt="挿入画像${i + 1}" class="inserted-image"></div>`;
      
      // 2枚目があれば追加
      if (i + 1 < imageUrls.length) {
        imageHtml += `<div class="image-item"><img src="${imageUrls[i + 1]}" alt="挿入画像${i + 2}" class="inserted-image"></div>`;
      }
      
      imageHtml += '</div>';
    }
    
    // 選択範囲に画像を挿入
    const selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = imageHtml;
    
    range.deleteContents();
    while (tempDiv.firstChild) {
      range.insertNode(tempDiv.firstChild);
    }
    
    // 選択をクリア
    selection.removeAllRanges();
    
    updateEditorContent();
  }

  // 画像モーダル初期化
  function initializeImageModal() {
    if (imageModalInitialized) return;
    
    const modal = document.querySelector('.image-modal');
    if (!modal) return;
    
    const imageInput = modal.querySelector('.image-input');
    const previewContainer = modal.querySelector('.image-preview-container');
    const previewGrid = modal.querySelector('.image-preview-grid');
    const insertBtn = modal.querySelector('.insert-images');
    const cancelBtn = modal.querySelector('.cancel-images');
    
    // ファイル選択時の処理
    imageInput.addEventListener('change', function(e) {
      const files = Array.from(e.target.files).slice(0, 5); // 最大5枚
      selectedFiles = files;
      
      if (files.length > 0) {
        previewContainer.style.display = 'block';
        previewGrid.innerHTML = '';
        
        files.forEach((file, index) => {
          const reader = new FileReader();
          reader.onload = function(e) {
            const previewItem = document.createElement('div');
            previewItem.className = 'image-preview-item';
            previewItem.innerHTML = `
              <img src="${e.target.result}" alt="プレビュー${index + 1}">
              <span class="image-number">${index + 1}</span>
            `;
            previewGrid.appendChild(previewItem);
          };
          reader.readAsDataURL(file);
        });
        
        insertBtn.disabled = false;
      } else {
        previewContainer.style.display = 'none';
        insertBtn.disabled = true;
      }
    });
    
    // 挿入ボタンのクリック処理
    insertBtn.addEventListener('click', function() {
      if (selectedFiles.length > 0) {
        uploadAndInsertImages(selectedFiles, currentRange);
      }
      closeImageModal();
    });
    
    // キャンセルボタンのクリック処理
    cancelBtn.addEventListener('click', closeImageModal);
    
    imageModalInitialized = true;
  }
  
  // 画像モーダルを閉じる
  function closeImageModal() {
    const modal = document.querySelector('.image-modal');
    const imageInput = modal.querySelector('.image-input');
    const previewContainer = modal.querySelector('.image-preview-container');
    const previewGrid = modal.querySelector('.image-preview-grid');
    const insertBtn = modal.querySelector('.insert-images');
    
    modal.style.display = 'none';
    imageInput.value = '';
    previewContainer.style.display = 'none';
    previewGrid.innerHTML = '';
    insertBtn.disabled = true;
    selectedFiles = [];
  }
} // setupRichEditor function end

// Taxonomy selection functionality
document.addEventListener('DOMContentLoaded', function() {
  // カテゴリ選択
    const categoryInput = document.querySelector('input[name="article[custom_fields][category]"]');
  const categorySuggestions = document.querySelector('.category-suggestions');
  
  if (categoryInput && categorySuggestions) {
    categorySuggestions.addEventListener('click', function(e) {
      if (e.target.classList.contains('category-tag')) {
        categoryInput.value = e.target.textContent.trim();
      }
    });
  }
  
  // タグ選択
  const tagInput = document.querySelector('input[name="article[custom_fields][tags]"]');
  const tagSuggestions = document.querySelector('.tags-suggestions');
  
  if (tagInput && tagSuggestions) {
    tagSuggestions.addEventListener('click', function(e) {
      if (e.target.classList.contains('tag-item')) {
        const currentTags = tagInput.value.split(',').map(tag => tag.trim()).filter(tag => tag);
        const newTag = e.target.textContent.trim();
        
        if (!currentTags.includes(newTag)) {
          currentTags.push(newTag);
          tagInput.value = currentTags.join(', ');
        }
      }
    });
  }
});

// リンク機能とSNSリンク機能
let currentSelection = null;
let selectedText = '';

// 選択範囲を保存する関数
function saveSelection() {
  const selection = window.getSelection();
  if (selection.rangeCount > 0) {
    currentSelection = selection.getRangeAt(0);
    selectedText = selection.toString();
  }
}

// 選択範囲を復元する関数
function restoreSelection() {
  if (currentSelection) {
    const selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(currentSelection);
  }
}

// 通常のリンク挿入
function handleLinkInsertion() {
  saveSelection();
  
  const linkModal = document.querySelector('.link-modal');
  const linkTextInput = linkModal.querySelector('.link-text');
  
  // 選択されたテキストがあれば表示テキストに設定
  if (selectedText) {
    linkTextInput.value = selectedText;
  }
  
  linkModal.style.display = 'block';
  linkModal.querySelector('.link-url').focus();
}

// SNSリンク挿入
function handleSnsLinkInsertion() {
  saveSelection();
  
  const snsLinkModal = document.querySelector('.sns-link-modal');
  snsLinkModal.style.display = 'block';
  snsLinkModal.querySelector('.sns-url').focus();
}

// リンクモーダルイベント
document.addEventListener('DOMContentLoaded', function() {
  const linkModal = document.querySelector('.link-modal');
  const snsLinkModal = document.querySelector('.sns-link-modal');
  
  if (!linkModal || !snsLinkModal) return;
  
  // リンク挿入実行
  document.querySelector('.insert-link').addEventListener('click', function() {
    const url = linkModal.querySelector('.link-url').value;
    const text = linkModal.querySelector('.link-text').value;
    
    if (!url) {
      alert('URLを入力してください');
      return;
    }
    
    const displayText = text || url;
    const linkHtml = `<a href="${url}" target="_blank" rel="noopener">${displayText}</a>`;
    
    restoreSelection();
    
    if (selectedText && currentSelection) {
      // 選択されたテキストを置換
      currentSelection.deleteContents();
      const range = currentSelection;
      const fragment = range.createContextualFragment(linkHtml);
      range.insertNode(fragment);
    } else {
      // カーソル位置に挿入
      document.execCommand('insertHTML', false, linkHtml);
    }
    
    // モーダルを閉じる
    linkModal.style.display = 'none';
    linkModal.querySelector('.link-url').value = '';
    linkModal.querySelector('.link-text').value = '';
    
    // エディタの内容を更新
    updateEditorContent();
  });
  
  // リンクモーダルキャンセル
  document.querySelector('.cancel-link').addEventListener('click', function() {
    linkModal.style.display = 'none';
    linkModal.querySelector('.link-url').value = '';
    linkModal.querySelector('.link-text').value = '';
  });
  
  // OGP情報取得
  document.querySelector('.fetch-ogp').addEventListener('click', function() {
    const url = snsLinkModal.querySelector('.sns-url').value;
    
    if (!url) {
      alert('URLを入力してください');
      return;
    }
    
    // ローディング表示
    this.textContent = '取得中...';
    this.disabled = true;
    
    // OGP情報を取得
    fetch('/admin/articles/fetch_ogp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ url: url })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        displayOGPPreview(data.ogp);
      } else {
        alert('OGP情報を取得できませんでした: ' + data.error);
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('エラーが発生しました');
    })
    .finally(() => {
      this.textContent = 'プレビューを取得';
      this.disabled = false;
    });
  });
  
  // OGPプレビュー表示
  function displayOGPPreview(ogp) {
    const preview = snsLinkModal.querySelector('.ogp-preview');
    const img = preview.querySelector('.ogp-image');
    const title = preview.querySelector('.ogp-title');
    const description = preview.querySelector('.ogp-description');
    const site = preview.querySelector('.ogp-site');
    
    if (ogp.image) {
      img.src = ogp.image;
      img.style.display = 'block';
    } else {
      img.style.display = 'none';
    }
    
    title.textContent = ogp.title || 'タイトルなし';
    description.textContent = ogp.description || '説明なし';
    site.textContent = ogp.site_name || new URL(snsLinkModal.querySelector('.sns-url').value).hostname;
    
    preview.style.display = 'block';
    snsLinkModal.querySelector('.insert-sns-link').style.display = 'inline-block';
    
    // プレビューデータを保存
    preview.dataset.ogpData = JSON.stringify(ogp);
  }
  
  // SNSリンク挿入実行
  document.querySelector('.insert-sns-link').addEventListener('click', function() {
    const url = snsLinkModal.querySelector('.sns-url').value;
    const preview = snsLinkModal.querySelector('.ogp-preview');
    const ogpData = JSON.parse(preview.dataset.ogpData || '{}');
    
    const snsLinkHtml = `
      <div class="sns-link-card" data-url="${url}">
        ${ogpData.image ? `<img src="${ogpData.image}" alt="OGP画像" class="sns-card-image">` : ''}
        <div class="sns-card-content">
          <h4 class="sns-card-title">${ogpData.title || 'タイトルなし'}</h4>
          <p class="sns-card-description">${ogpData.description || '説明なし'}</p>
          <small class="sns-card-site">${ogpData.site_name || new URL(url).hostname}</small>
          <a href="${url}" target="_blank" rel="noopener" class="sns-card-link">リンクを開く</a>
        </div>
      </div>
    `;
    
    restoreSelection();
    document.execCommand('insertHTML', false, snsLinkHtml);
    
    // モーダルを閉じる
    closeSnsModal();
    
    // エディタの内容を更新
    updateEditorContent();
  });
  
  // SNSモーダルキャンセル
  document.querySelector('.cancel-sns-link').addEventListener('click', function() {
    closeSnsModal();
  });
  
  function closeSnsModal() {
    snsLinkModal.style.display = 'none';
    snsLinkModal.querySelector('.sns-url').value = '';
    snsLinkModal.querySelector('.ogp-preview').style.display = 'none';
    snsLinkModal.querySelector('.insert-sns-link').style.display = 'none';
  }
  
  // エディタの内容を更新
  function updateEditorContent() {
    const editor = document.querySelector('.editor-content');
    const hiddenField = document.getElementById('content_json_hidden');
    if (hiddenField && editor) {
      hiddenField.value = editor.innerHTML;
    }
  }
  
  // URL自動検出とSNSリンクカード変換機能
  const editor = document.querySelector('.editor-content');
  if (editor) {
    let timeoutId;
    let globalProcessedUrls = new Set(); // グローバルで処理済みURLを記録
    
    editor.addEventListener('input', function() {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => {
        autoConvertUrls();
      }, 1000); // 1秒後にURL検出を実行
    });
    
    function autoConvertUrls() {
      const content = editor.innerHTML;
      const urlRegex = /https?:\/\/(www\.)?(twitter\.com|x\.com|instagram\.com|facebook\.com|youtube\.com|tiktok\.com)\/[^\s<]+/gi;
      let match;
      
      // 既存のSNSカードのURLを取得してグローバルセットに追加
      const existingCards = editor.querySelectorAll('.sns-link-card');
      existingCards.forEach(card => {
        const existingUrl = card.dataset.url;
        if (existingUrl) {
          globalProcessedUrls.add(existingUrl);
        }
      });
      
      // 新しいURLを検出
      const detectedUrls = [];
      while ((match = urlRegex.exec(content)) !== null) {
        const url = match[0];
        
        // グローバルで処理済みのURLまたは既にカードになっているURLはスキップ
        if (!globalProcessedUrls.has(url) && !content.includes(`data-url="${url}"`)) {
          detectedUrls.push(url);
        }
      }
      
      // 検出された新しいURLがある場合、一度だけ確認
      if (detectedUrls.length > 0) {
        const urlList = detectedUrls.join('\n');
        const shouldConvert = confirm(`SNSのURLが検出されました。リンクカードに変換しますか？\n\n${urlList}`);
        
        if (shouldConvert) {
          detectedUrls.forEach(url => {
            globalProcessedUrls.add(url); // 処理済みとしてマーク
            convertUrlToSnsCard(url);
          });
        } else {
          // ユーザーが拒否した場合も処理済みとしてマークして再度確認しないようにする
          detectedUrls.forEach(url => {
            globalProcessedUrls.add(url);
          });
        }
      }
    }
    
    function convertUrlToSnsCard(url) {
      // OGP情報を取得してリンクカードに変換
      fetch('/admin/articles/fetch_ogp', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ url: url })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          const ogp = data.ogp;
          const snsLinkHtml = `
            <div class="sns-link-card" data-url="${url}">
              ${ogp.image ? `<img src="${ogp.image}" alt="OGP画像" class="sns-card-image">` : ''}
              <div class="sns-card-content">
                <h4 class="sns-card-title">${ogp.title || 'タイトルなし'}</h4>
                <p class="sns-card-description">${ogp.description || '説明なし'}</p>
                <small class="sns-card-site">${ogp.site_name || new URL(url).hostname}</small>
                <a href="${url}" target="_blank" rel="noopener" class="sns-card-link">リンクを開く</a>
              </div>
            </div>
          `;
          
          // 元のURLをリンクカードに置換
          editor.innerHTML = editor.innerHTML.replace(url, snsLinkHtml);
          updateEditorContent();
        }
      })
      .catch(error => {
        console.error('Error:', error);
      });
    }
    
  }
});