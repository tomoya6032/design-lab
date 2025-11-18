// 管理画面のメディア管理用JavaScript
document.addEventListener('DOMContentLoaded', function() {
  console.log('Media admin JavaScript loaded');
  
  // メディア削除の確認ダイアログ
  function setupMediaDeleteConfirmation() {
    const deleteButtons = document.querySelectorAll('.delete-media-btn');
    deleteButtons.forEach(button => {
      button.addEventListener('click', function(e) {
        e.preventDefault();
        
        const form = this.closest('form');
        const mediaName = this.getAttribute('data-media-name') || '選択したメディア';
        
        // カスタム確認ダイアログを表示
        const confirmDelete = confirm(
          `「${mediaName}」を削除してよろしいですか？\n\nこの操作は元に戻せません。`
        );
        
        if (confirmDelete) {
          // 削除を実行
            if (form) {
              // if a form exists (e.g., button_to), submit it
              form.submit();
              return;
            }

            // if no form exists, build one (so link_to without method still works)
            try {
              const action = this.getAttribute('href') || window.location.pathname + '/' + this.getAttribute('data-media-id');
              const builtForm = document.createElement('form');
              builtForm.method = 'POST';
              builtForm.action = action;

              // CSRF token
              const meta = document.querySelector('meta[name="csrf-token"]');
              if (meta) {
                const tokenInput = document.createElement('input');
                tokenInput.type = 'hidden';
                tokenInput.name = 'authenticity_token';
                tokenInput.value = meta.getAttribute('content');
                builtForm.appendChild(tokenInput);
              }

              // Emulate _method DELETE
              const methodInput = document.createElement('input');
              methodInput.type = 'hidden';
              methodInput.name = '_method';
              methodInput.value = 'delete';
              builtForm.appendChild(methodInput);

              document.body.appendChild(builtForm);
              builtForm.submit();
            } catch (err) {
              // fallback: if anything goes wrong, navigate to href (will typically show the page)
              console.error('Failed to submit delete form programmatically:', err);
              const href = this.getAttribute('href');
              if (href) window.location.href = href;
            }
        }
      });
    });
  }

  // メディア選択機能（記事作成時のメディア選択）
  function setupMediaSelection() {
    const mediaSelectButtons = document.querySelectorAll('.media-select-btn');
    mediaSelectButtons.forEach(button => {
      button.addEventListener('click', function(e) {
        e.preventDefault();
        
        const mediaId = this.getAttribute('data-media-id');
        const mediaUrl = this.getAttribute('data-media-url');
        const mediaName = this.getAttribute('data-media-name');
        
        // 親ウィンドウに選択されたメディア情報を送信
        if (window.opener && window.opener.selectMedia) {
          window.opener.selectMedia(mediaId, mediaUrl, mediaName);
          window.close();
        }
      });
    });
  }

  // 全選択/個別選択の機能
  function setupBulkSelection() {
    const selectAllCheckbox = document.getElementById('select-all-media');
    const mediaCheckboxes = document.querySelectorAll('input[name="media_ids[]"]');
    
    if (selectAllCheckbox) {
      selectAllCheckbox.addEventListener('change', function() {
        const isChecked = this.checked;
        mediaCheckboxes.forEach(checkbox => {
          checkbox.checked = isChecked;
        });
      });
    }

    // 個別チェックボックスの変更を監視
    mediaCheckboxes.forEach(checkbox => {
      checkbox.addEventListener('change', function() {
        updateSelectAllState();
      });
    });
  }

  function updateSelectAllState() {
    const selectAllCheckbox = document.getElementById('select-all-media');
    const mediaCheckboxes = document.querySelectorAll('input[name="media_ids[]"]');
    
    if (!selectAllCheckbox) return;
    
    const totalCount = mediaCheckboxes.length;
    const checkedCount = Array.from(mediaCheckboxes).filter(checkbox => checkbox.checked).length;
    
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

  // 初期化
  setupMediaDeleteConfirmation();
  setupMediaSelection();
  setupBulkSelection();
});