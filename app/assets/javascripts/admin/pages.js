// 管理画面の固定ページ一覧用JavaScript
document.addEventListener('DOMContentLoaded', function() {
  const selectAllCheckbox = document.getElementById('select-all-pages');
  const pageCheckboxes = document.querySelectorAll('input[name="page_ids[]"]');
  const bulkActionSelect = document.getElementById('bulk-action-select-pages');
  const bulkActionBtn = document.getElementById('bulk-action-btn-pages');
  const selectedCount = document.getElementById('selected-count-pages');
  const countNumber = document.getElementById('count-number-pages');
  const bulkActionForm = document.getElementById('bulk-action-form-pages');

  // 全選択/全解除の機能
  if (selectAllCheckbox) {
    selectAllCheckbox.addEventListener('change', function() {
      const isChecked = this.checked;
      pageCheckboxes.forEach(checkbox => {
        checkbox.checked = isChecked;
      });
      updateBulkActions();
    });
  }

  // 個別チェックボックスの変更を監視
  pageCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      updateBulkActions();
      updateSelectAllState();
    });
  });

  // 一括操作ボタンのクリックイベント
  if (bulkActionBtn) {
    bulkActionBtn.addEventListener('click', function(e) {
      e.preventDefault();
      const checkedCount = getCheckedCount();
      const selectedAction = bulkActionSelect.value;
      
      if (checkedCount === 0) {
        alert('操作するページを選択してください。');
        return;
      }
      
      if (!selectedAction) {
        alert('一括操作を選択してください。');
        return;
      }
      
      const actionMessages = {
        'publish': '公開',
        'draft': '下書きに戻す',
        'delete': '削除'
      };
      
      const actionMessage = actionMessages[selectedAction] || '操作';
      let confirmMessage = `選択した${checkedCount}件のページを${actionMessage}しますか？`;
      
      if (selectedAction === 'delete') {
        confirmMessage += 'この操作は取り消せません。';
      }
      
      if (confirm(confirmMessage)) {
        bulkActionForm.submit();
      }
    });
  }

  // 一括操作の表示/非表示と選択数の更新
  function updateBulkActions() {
    const checkedCount = getCheckedCount();
    
    if (checkedCount > 0) {
      bulkActionSelect.disabled = false;
      bulkActionBtn.disabled = false;
      selectedCount.style.display = 'inline-block';
      countNumber.textContent = checkedCount;
    } else {
      bulkActionSelect.disabled = true;
      bulkActionSelect.value = '';
      bulkActionBtn.disabled = true;
      selectedCount.style.display = 'none';
    }
  }

  // 全選択チェックボックスの状態を更新
  function updateSelectAllState() {
    if (!selectAllCheckbox) return;
    
    const checkedCount = getCheckedCount();
    const totalCount = pageCheckboxes.length;
    
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

  // チェックされたアイテム数を取得
  function getCheckedCount() {
    return Array.from(pageCheckboxes).filter(checkbox => checkbox.checked).length;
  }

  // 初期状態の設定
  updateBulkActions();
  updateSelectAllState();
});