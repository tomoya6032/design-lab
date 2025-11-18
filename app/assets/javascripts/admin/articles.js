// 管理画面の記事一覧用JavaScript
document.addEventListener('DOMContentLoaded', function() {
  const selectAllCheckbox = document.getElementById('select-all');
  const articleCheckboxes = document.querySelectorAll('input[name="article_ids[]"]');
  const bulkActionSelect = document.getElementById('bulk-action-select');
  // id unified with template/application.js
  const bulkActionBtn = document.getElementById('bulk-action-button');
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
      const selectedAction = bulkActionSelect ? bulkActionSelect.value : null;
      
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
        // ensure CSRF token exists on the form before submit and handle missing form
          if (bulkActionForm) {
          if (!bulkActionForm.querySelector('input[name="authenticity_token"]')) {
            const meta = document.querySelector('meta[name="csrf-token"]');
            if (meta) {
              const tokenInput = document.createElement('input');
              tokenInput.type = 'hidden';
              tokenInput.name = 'authenticity_token';
              tokenInput.value = meta.getAttribute('content');
              bulkActionForm.appendChild(tokenInput);
            }
          }
          // submit via fetch as temporary workaround
          try {
            const csrf = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
            const fd = new FormData(bulkActionForm);
            const methodEl = bulkActionForm.querySelector('input[name="_method"]');
            const method = methodEl ? methodEl.value.toUpperCase() : (bulkActionForm.getAttribute('method') || 'POST').toUpperCase();
            fetch(bulkActionForm.action, { method: method === 'GET' ? 'POST' : method, headers: { 'X-CSRF-Token': csrf, 'Accept': 'text/html' }, body: fd, credentials: 'same-origin' }).then(r => { if (r.redirected) window.location = r.url; else window.location.reload(); }).catch(e => { console.error('Bulk action fetch failed', e); bulkActionForm.submit(); });
          } catch (e) { console.error('Bulk action fetch error', e); bulkActionForm.submit(); }
        } else {
          // Fallback: create a temporary form (mirrors application.js behavior)
          const form = document.createElement('form');
          form.method = 'POST';
          form.action = window.location.pathname + '/bulk_action';
          const meta = document.querySelector('meta[name="csrf-token"]');
          if (meta) {
            const tokenInput = document.createElement('input');
            tokenInput.type = 'hidden';
            tokenInput.name = 'authenticity_token';
            tokenInput.value = meta.getAttribute('content');
            form.appendChild(tokenInput);
          }
          const methodInput = document.createElement('input');
          methodInput.type = 'hidden';
          methodInput.name = '_method';
          methodInput.value = 'PATCH';
          form.appendChild(methodInput);
          const actionInput = document.createElement('input');
          actionInput.type = 'hidden';
          actionInput.name = 'bulk_action';
          actionInput.value = selectedAction || '';
          form.appendChild(actionInput);
          const boxes = document.querySelectorAll('input[name="article_ids[]"]:checked');
          boxes.forEach(cb => {
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = cb.name;
            idInput.value = cb.value;
            form.appendChild(idInput);
          });
          document.body.appendChild(form);
          form.submit();
        }
      }
    });
  }

  // 一括操作の表示/非表示と選択数の更新
  function updateBulkActions() {
    const checkedCount = getCheckedCount();
    
    if (checkedCount > 0) {
      if (bulkActionSelect) bulkActionSelect.disabled = false;
      if (bulkActionBtn) bulkActionBtn.disabled = false;
      if (selectedCount) selectedCount.style.display = 'inline-block';
      if (countNumber) countNumber.textContent = checkedCount;
    } else {
      if (bulkActionSelect) { bulkActionSelect.disabled = true; try { bulkActionSelect.value = ''; } catch(e) {} }
      if (bulkActionBtn) bulkActionBtn.disabled = true;
      if (selectedCount) selectedCount.style.display = 'none';
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
          // CSRFトークンhiddenがなければ追加
          if (form && !form.querySelector('input[name="authenticity_token"]')) {
            const meta = document.querySelector('meta[name="csrf-token"]');
            if (meta) {
              const input = document.createElement('input');
              input.type = 'hidden';
              input.name = 'authenticity_token';
              input.value = meta.content;
              form.appendChild(input);
            }
          }
          form.submit();
        }
      });
    });
  // 一括操作フォームのCSRFトークン補完
  // also ensure the form has token on submit (safety net)
  if (bulkActionForm) {
    bulkActionForm.addEventListener('submit', function(e) {
      if (!bulkActionForm.querySelector('input[name="authenticity_token"]')) {
        const meta = document.querySelector('meta[name="csrf-token"]');
        if (meta) {
          const input = document.createElement('input');
          input.type = 'hidden';
          input.name = 'authenticity_token';
          input.value = meta.getAttribute('content');
          bulkActionForm.appendChild(input);
        }
      }
    });
  }
  }

  // 初期状態の設定
  updateBulkActions();
  updateSelectAllState();
  setupDeleteConfirmation();
});