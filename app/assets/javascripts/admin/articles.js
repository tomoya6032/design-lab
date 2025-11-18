// 管理画面の記事一覧用JavaScript
document.addEventListener('DOMContentLoaded', function() {
  const selectAllCheckbox = document.getElementById('select-all');
  const articleCheckboxes = document.querySelectorAll('input[name="article_ids[]"]');
  const bulkActionSelect = document.getElementById('bulk-action-select');
  const bulkActionBtn = document.getElementById('bulk-action-btn');
  const selectedCount = document.getElementById('selected-count');
  const countNumber = document.getElementById('count-number');
  const bulkActionForm = document.getElementById('bulk-action-form');

  // 全選択/全解除の機能
  if (selectAllCheckbox) {
    selectAllCheckbox.addEventListener('change', function() {
      const isChecked = this.checked;
      articleCheckboxes.forEach(checkbox => {
        checkbox.checked = isChecked;
      });
      updateBulkActions();
    });
  }

  // 個別チェックボックスの変更を監視
  articleCheckboxes.forEach(checkbox => {
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
        alert('操作する記事を選択してください。');
        return;
      }
      
      if (!selectedAction) {
        alert('一括操作を選択してください。');
        return;
      }
      
      const actionMessages = {
        'publish': '公開',
        'draft': '下書きに戻す',
        'unpublish': '非公開化',
        'delete': '削除'
      };
      
      const actionMessage = actionMessages[selectedAction] || '操作';
      let confirmMessage = `選択した${checkedCount}件の記事を${actionMessage}しますか？`;
      
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
    const totalCount = articleCheckboxes.length;
    
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
    return Array.from(articleCheckboxes).filter(checkbox => checkbox.checked).length;
  }

  // 削除ボタンの確認ダイアログ
  function setupDeleteConfirmation() {
    const deleteButtons = document.querySelectorAll('.delete-article-btn');
    deleteButtons.forEach(button => {
      button.addEventListener('click', function(e) {
        e.preventDefault();
        
        const form = this.closest('form');
        const articleTitle = this.getAttribute('data-article-title') || '選択した記事';
        
        // カスタム確認ダイアログを表示
        const confirmDelete = confirm(
          `「${articleTitle}」を削除してよろしいですか？\n\nこの操作は元に戻せません。`
        );
        
        if (confirmDelete) {
          // 削除を実行
          form.submit();
        }
      });
    });
  }

  // 初期状態の設定
  updateBulkActions();
  updateSelectAllState();
  setupDeleteConfirmation();
});