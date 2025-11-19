// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

console.log("Design Lab CMS - Application loaded");

// 一括操作機能
document.addEventListener('DOMContentLoaded', function() {
  
  // Cropper.jsをCDN経由で動的に読み込み（DOMContentLoaded後に定義）
  window.loadCropperJS = function() {
    console.log('loadCropperJS関数が呼び出されました');
    return new Promise((resolve, reject) => {
      if (typeof window.Cropper !== 'undefined') {
        console.log('Cropper.jsは既に読み込まれています');
        resolve(window.Cropper);
        return;
      }

      console.log('Cropper.jsをCDN経由で読み込み開始...');
      
      // CSS読み込み
      const cssLink = document.createElement('link');
      cssLink.rel = 'stylesheet';
      cssLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.css';
      document.head.appendChild(cssLink);
      
      // JavaScript読み込み
      const script = document.createElement('script');
      script.src = 'https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.js';
      script.onload = function() {
        console.log('=== Cropper.js CDN読み込み完了 ===');
        console.log('window.Cropper:', typeof window.Cropper);
        resolve(window.Cropper);
      };
      script.onerror = function() {
        console.error('Cropper.jsの読み込みに失敗');
        reject(new Error('Cropper.jsの読み込みに失敗'));
      };
      document.head.appendChild(script);
    });
  };
  
  console.log('loadCropperJS関数を定義しました:', typeof window.loadCropperJS);
  // 全選択チェックボックス
  const selectAllCheckbox = document.getElementById('select-all');
  const itemCheckboxes = document.querySelectorAll('.item-checkbox');
  const bulkActionSelect = document.getElementById('bulk-action-select');
  const bulkActionButton = document.getElementById('bulk-action-button');

  // 全選択機能
  if (selectAllCheckbox) {
    selectAllCheckbox.addEventListener('change', function() {
      itemCheckboxes.forEach(checkbox => {
        checkbox.checked = this.checked;
      });
      updateBulkActionButtonState();
    });
  }

  // 個別チェックボックスの状態変更
  itemCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      updateSelectAllState();
      updateBulkActionButtonState();
    });
  });

  // 全選択チェックボックスの状態を更新
  function updateSelectAllState() {
    if (!selectAllCheckbox) return;
    
    const checkedCount = document.querySelectorAll('.item-checkbox:checked').length;
    const totalCount = itemCheckboxes.length;
    
    if (checkedCount === 0) {
      selectAllCheckbox.checked = false;
      selectAllCheckbox.indeterminate = false;
    } else if (checkedCount === totalCount) {
      selectAllCheckbox.checked = true;
      selectAllCheckbox.indeterminate = false;
    } else {
      selectAllCheckbox.checked = false;
      selectAllCheckbox.indeterminate = true;
    }
  }

  // 一括操作ボタンの状態を更新
  function updateBulkActionButtonState() {
    const checkedCount = document.querySelectorAll('.item-checkbox:checked').length;
    const hasAction = bulkActionSelect && bulkActionSelect.value !== '';
    
    if (bulkActionButton) {
      bulkActionButton.disabled = checkedCount === 0 || !hasAction;
    }
  }

  // 一括操作セレクトの変更
  if (bulkActionSelect) {
    bulkActionSelect.addEventListener('change', function() {
      updateBulkActionButtonState();
    });
  }

  // 一括操作の実行
  if (bulkActionButton) {
    bulkActionButton.addEventListener('click', function(e) {
      e.preventDefault();
      
      const checkedBoxes = document.querySelectorAll('.item-checkbox:checked');
      const action = bulkActionSelect.value;
      
      if (checkedBoxes.length === 0) {
        alert('操作するアイテムを選択してください。');
        return;
      }
      
      if (!action) {
        alert('実行する操作を選択してください。');
        return;
      }
      
      // 確認ダイアログ
      let confirmMessage = '';
      switch(action) {
        case 'delete':
          confirmMessage = `選択した${checkedBoxes.length}件のアイテムを削除しますか？この操作は取り消せません。`;
          break;
        case 'published':
          confirmMessage = `選択した${checkedBoxes.length}件のアイテムを公開しますか？`;
          break;
        case 'draft':
          confirmMessage = `選択した${checkedBoxes.length}件のアイテムを下書きに戻しますか？`;
          break;
        case 'limited':
          confirmMessage = `選択した${checkedBoxes.length}件のアイテムを限定公開にしますか？`;
          break;
        default:
          confirmMessage = `選択した${checkedBoxes.length}件のアイテムに対して「${action}」を実行しますか？`;
      }
      
      if (!confirm(confirmMessage)) {
        return;
      }
      
      console.log('=== 一括操作 DEBUG ===');
      console.log('Action:', action);
      console.log('Selected checkboxes:', checkedBoxes.length);
      console.log('Form exists:', !!document.getElementById('bulk-action-form'));
      
      // 既存のフォームを使用して送信
      const existingForm = document.getElementById('bulk-action-form');
      if (existingForm) {
        // セレクトボックスの値を設定
        bulkActionSelect.value = action;
        
        // チェックされていないチェックボックスを一時的に無効化
        const allCheckboxes = document.querySelectorAll('.item-checkbox');
        allCheckboxes.forEach(checkbox => {
          if (!checkbox.checked) {
            checkbox.disabled = true;
          }
        });
        
<<<<<<< HEAD
        // Debug: log token and method just before submitting existing form
        try {
          const tokenInput = existingForm.querySelector('input[name="authenticity_token"]');
          const tokenVal = tokenInput ? tokenInput.value : (document.querySelector('meta[name="csrf-token"]') || {}).content;
          const methodInput = existingForm.querySelector('input[name="_method"]');
          console.log('CSRF-DEBUG: submitting existingForm, token_len=', tokenVal ? tokenVal.length : null, 'token_head=', tokenVal ? tokenVal.slice(0,8) : null, '_method=', methodInput ? methodInput.value : (existingForm.getAttribute('method') || 'GET'));
        } catch (e) {
          console.warn('CSRF-DEBUG: error reading token for existingForm', e);
        }
        // フォーム送信を fetch に置き換え（一時的な回避策）
        try {
          const csrf = (document.querySelector('meta[name="csrf-token"]') || {}).getAttribute('content');
          const formData = new FormData(existingForm);
          // Normalize to POST + _method=PATCH for bulk actions to avoid accidental DELETE method
          if (existingForm.id === 'bulk-action-form') {
            formData.set('_method', 'PATCH');
          }
          // Debug: log what _method will be sent
          try {
            const sentMethod = formData.get('_method') || (existingForm.getAttribute('method') || 'POST');
            console.log('CSRF-DEBUG: bulk_action sending with _method=', sentMethod);
          } catch (e) {
            // ignore
          }
          // Force using POST so method override is carried in formData
          const fetchMethod = 'POST';
          fetch(existingForm.action, {
            method: fetchMethod,
            headers: {
              'X-CSRF-Token': csrf,
              'Accept': 'text/html'
            },
=======
        // フォーム送信を fetch に置き換え（一時回避策: ヘッダで CSRF トークンを送る）
        try {
          const csrf = (document.querySelector('meta[name="csrf-token"]') || {}).getAttribute('content');
          const formData = new FormData(existingForm);
          // Ensure method override is PATCH for bulk actions
          formData.set('_method', 'PATCH');
          console.log('CSRF-DEBUG: sending bulk_action via fetch, _method=', formData.get('_method'));
          fetch(existingForm.action, {
            method: 'POST',
            headers: { 'X-CSRF-Token': csrf, 'Accept': 'text/html' },
>>>>>>> 50591ffefdbdbf8d7a21baddea993c175fe737ee
            body: formData,
            credentials: 'same-origin'
          }).then(resp => {
            if (resp.redirected) {
              window.location = resp.url;
            } else {
              window.location.reload();
            }
          }).catch(err => {
<<<<<<< HEAD
            console.error('Bulk action fetch error:', err);
            existingForm.submit(); // fallback to traditional submit
          });
        } catch (e) {
          console.error('Bulk action fetch failed, falling back to form submit', e);
=======
            console.error('Bulk action fetch error, falling back to form.submit()', err);
            existingForm.submit();
          });
        } catch (e) {
          console.error('Bulk action fetch failed, falling back to submit', e);
>>>>>>> 50591ffefdbdbf8d7a21baddea993c175fe737ee
          existingForm.submit();
        }
      } else {
        // フォールバック: 新しいフォームを作成
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = window.location.pathname + '/bulk_action';
        
        // CSRF トークンを追加
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
        const csrfInput = document.createElement('input');
        csrfInput.type = 'hidden';
        csrfInput.name = 'authenticity_token';
        csrfInput.value = csrfToken;
        form.appendChild(csrfInput);
        
        // PATCHメソッドを指定
        const methodInput = document.createElement('input');
        methodInput.type = 'hidden';
        methodInput.name = '_method';
        methodInput.value = 'PATCH';
        form.appendChild(methodInput);
        
        // アクションを追加
        const actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'bulk_action';
        actionInput.value = action;
        form.appendChild(actionInput);
        
        // 選択されたIDを追加
        checkedBoxes.forEach(checkbox => {
          const idInput = document.createElement('input');
          idInput.type = 'hidden';
          idInput.name = checkbox.name; // 'article_ids[]' or 'page_ids[]'
          idInput.value = checkbox.value;
          form.appendChild(idInput);
        });
        
        document.body.appendChild(form);
        // Debug: log token and method for dynamically created form
        try {
          const createdToken = form.querySelector('input[name="authenticity_token"]').value;
          const createdMethod = form.querySelector('input[name="_method"]').value;
          console.log('CSRF-DEBUG: submitting dynamic form, token_len=', createdToken ? createdToken.length : null, 'token_head=', createdToken ? createdToken.slice(0,8) : null, '_method=', createdMethod);
        } catch (e) {
          console.warn('CSRF-DEBUG: error reading token for dynamic form', e);
        }
        // dynamic form: use fetch instead of direct submit
        try {
          const csrf = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
          const formData = new FormData(form);
          fetch(form.action, {
            method: 'POST',
            headers: { 'X-CSRF-Token': csrf, 'Accept': 'text/html' },
            body: formData,
            credentials: 'same-origin'
          }).then(resp => { if (resp.redirected) window.location = resp.url; else window.location.reload(); }).catch(err => { console.error('Bulk action fetch error:', err); form.submit(); });
        } catch (e) {
          console.error('Bulk action dynamic fetch failed, falling back to submit', e);
          form.submit();
        }
      }
    });
  }
  
  // 初期状態を設定
  updateBulkActionButtonState();
});

<<<<<<< HEAD
  // Global safety: ensure forms have authenticity_token before submission
  document.addEventListener('submit', function(event) {
    try {
      const form = event.target;
      if (!(form instanceof HTMLFormElement)) return;

      // Only act for non-GET submits
      const method = (form.getAttribute('method') || 'get').toUpperCase();
      if (method === 'GET') return;

      // If authenticity_token missing, add it from meta
      if (!form.querySelector('input[name="authenticity_token"]')) {
        const meta = document.querySelector('meta[name="csrf-token"]');
        if (meta) {
          const input = document.createElement('input');
          input.type = 'hidden';
          input.name = 'authenticity_token';
          input.value = meta.getAttribute('content');
          form.appendChild(input);
        }
      }

      // Debug: log on submit what token is being sent (length and head) and _method if present
      try {
        const outTokenEl = form.querySelector('input[name="authenticity_token"]');
        const outToken = outTokenEl ? outTokenEl.value : null;
        const outMethodEl = form.querySelector('input[name="_method"]');
        const outMethod = outMethodEl ? outMethodEl.value : (form.getAttribute('method') || 'GET');
        console.log('CSRF-DEBUG: form submit detected, token_len=', outToken ? outToken.length : null, 'token_head=', outToken ? outToken.slice(0,8) : null, '_method=', outMethod);
      } catch (e) {
        console.warn('CSRF-DEBUG: error logging form submit token', e);
      }

      // If form intends to use PATCH/DELETE but lacks _method hidden, add it as fallback
      const action = (form.getAttribute('data-method') || '').toLowerCase();
      if (!form.querySelector('input[name="_method"]')) {
        // inspect any data-method on links/buttons or a data attribute on form
        const methodOverride = form.getAttribute('data-method') || form.getAttribute('data-remote-method');
        if (methodOverride) {
          const mi = document.createElement('input');
          mi.type = 'hidden';
          mi.name = '_method';
          mi.value = methodOverride;
          form.appendChild(mi);
        }
      }
      // If this is a bulk_action endpoint but _method was set to delete (e.g., by mistake), normalize to PATCH
      try {
        const bulkActionInput = form.querySelector('input[name="bulk_action"]');
        const methodInput = form.querySelector('input[name="_method"]');
        if (bulkActionInput && methodInput && methodInput.value.toLowerCase() === 'delete') {
          methodInput.value = 'patch';
        }
      } catch (e) {
        // ignore
      }
    } catch (e) {
      // don't block submission on error
      console.error('CSRF safety hook error:', e);
    }
  }, true);

  // Intercept single-article delete buttons (button_to generates a form)
  document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.delete-article-btn').forEach(btn => {
      // button_to renders a form around the button; find the closest form
      const form = btn.closest('form');
      if (!form) return;

      btn.addEventListener('click', function(event) {
        // allow default confirmation behavior provided by Rails UJS if present
        // but intercept actual network submission to attach X-CSRF-Token header
        try {
          // If the button has data-confirm attribute, respect it
          const confirmMsg = btn.getAttribute('data-confirm');
          if (confirmMsg && !window.confirm(confirmMsg)) {
            event.preventDefault();
            return;
          }

          event.preventDefault();

          // Prepare FormData and fetch
          const action = form.getAttribute('action') || window.location.pathname;
          let method = 'POST';
          const methodInput = form.querySelector('input[name="_method"]');
          if (methodInput && methodInput.value) method = methodInput.value.toUpperCase();
          // default button_to with method: :delete will include _method=delete

          const formData = new FormData(form);
          // ensure authenticity_token exists in formData
          if (!formData.get('authenticity_token')) {
            const meta = document.querySelector('meta[name="csrf-token"]');
            if (meta) formData.set('authenticity_token', meta.getAttribute('content'));
          }

          const csrf = (document.querySelector('meta[name="csrf-token"]') || {}).getAttribute('content');

          fetch(action, {
            method: method === 'GET' ? 'POST' : method,
            headers: { 'X-CSRF-Token': csrf, 'Accept': 'text/html' },
            body: formData,
            credentials: 'same-origin'
          }).then(resp => {
            if (resp.redirected) {
              window.location = resp.url;
            } else {
              // reload to reflect deletion
              window.location.reload();
            }
          }).catch(err => {
            console.error('Single delete fetch error, falling back to form submit', err);
            form.submit();
          });
        } catch (e) {
          console.error('Error in single delete handler, allowing default submit', e);
        }
      });
    });
  });
=======
// Capture-phase submit handler: intercept bulk-action form submits and send via fetch with X-CSRF-Token
document.addEventListener('submit', function(e) {
  try {
    const form = e.target;
    if (!(form instanceof HTMLFormElement)) return;
    if (form.id !== 'bulk-action-form') return;

    // prevent any native submit (and any other handlers) and send via fetch
    e.preventDefault();
    e.stopImmediatePropagation();

    const csrf = (document.querySelector('meta[name="csrf-token"]') || {}).getAttribute('content');
    const formData = new FormData(form);
    formData.set('_method', 'PATCH');

    console.log('CSRF-DEBUG: intercepted bulk-action submit, sending via fetch, _method=', formData.get('_method'));

    fetch(form.action, {
      method: 'POST',
      headers: { 'X-CSRF-Token': csrf, 'Accept': 'text/html' },
      body: formData,
      credentials: 'same-origin'
    }).then(resp => {
      if (resp.redirected) {
        window.location = resp.url;
      } else {
        window.location.reload();
      }
    }).catch(err => {
      console.error('CSRF-DEBUG: bulk-action fetch failed, falling back to form.submit()', err);
      // last-resort: allow native submit
      form.submit();
    });
  } catch (e) {
    console.error('CSRF-DEBUG: error in bulk-action submit interceptor', e);
  }
}, true);
>>>>>>> 50591ffefdbdbf8d7a21baddea993c175fe737ee
