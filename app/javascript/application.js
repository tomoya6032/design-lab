// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

console.log("Design Lab CMS - Application loaded");

// 一括操作機能
document.addEventListener('DOMContentLoaded', function() {
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
        
        // フォームを送信
        existingForm.submit();
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
        form.submit();
      }
    });
  }
  
  // 初期状態を設定
  updateBulkActionButtonState();
});
