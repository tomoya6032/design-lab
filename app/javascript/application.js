// app/javascript/application.js
// Consolidated client-side behaviors for admin: select-all, bulk actions,
// single-item delete interception, and safety hooks to ensure authenticity_token
// This file keeps the newer fetch-based CSRF flows (X-CSRF-Token header) and
// falls back to native form submission on errors.

function csrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute('content') : '';
}

function ensureHiddenInput(form, name, value) {
  if (!form.querySelector(`input[name="${name}"]`)) {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = name;
    input.value = value;
    form.appendChild(input);
  }
}

async function sendFormDataWithCsrf(form, methodOverride = null) {
  try {
    const fd = new FormData(form);
    if (methodOverride) fd.set('_method', methodOverride);

    const token = csrfToken();
    const res = await fetch(form.action, {
      method: 'POST',
      headers: token ? { 'X-CSRF-Token': token } : {},
      body: fd,
      credentials: 'same-origin'
    });

    if (!res.ok) throw new Error('Network response was not ok');

    // On success, if the server redirected or returned json with a URL,
    // prefer to reload or navigate. Simplest approach: reload page.
    window.location.reload();
  } catch (e) {
    // Fallback to native submit when fetch fails
    form.submit();
  }
}

document.addEventListener('DOMContentLoaded', function () {
  // --- Select all / item checkbox synchronization ---
  const selectAll = document.querySelector('#select-all');
  const itemCheckboxes = Array.from(document.querySelectorAll('.item-checkbox'));
  const bulkActionSelect = document.querySelector('#bulk-action-select');
  const bulkActionButton = document.querySelector('#bulk-action-button');
  const bulkForm = document.querySelector('#bulk-action-form');

  function updateBulkState() {
    const anyChecked = itemCheckboxes.some(cb => cb.checked);
    if (bulkActionButton) bulkActionButton.disabled = !anyChecked;
    if (bulkActionSelect) {
      try { bulkActionSelect.disabled = !anyChecked; } catch (e) {}
      try { bulkActionSelect.value = anyChecked ? bulkActionSelect.value : ''; } catch (e) {}
    }
  }

  if (selectAll) {
    selectAll.addEventListener('change', () => {
      itemCheckboxes.forEach(cb => { cb.checked = selectAll.checked; });
      updateBulkState();
    });
  }

  itemCheckboxes.forEach(cb => cb.addEventListener('change', updateBulkState));
  updateBulkState();

  // --- Bulk action submit (capture to intercept native submit) ---
  if (bulkForm) {
    bulkForm.addEventListener('submit', function (ev) {
      ev.preventDefault();
      // ensure authenticity_token is present
      ensureHiddenInput(bulkForm, 'authenticity_token', csrfToken());
      // Use PATCH override when performing bulk updates
      sendFormDataWithCsrf(bulkForm, 'PATCH');
    }, true);
  }

  // --- Single item delete interception ---
  document.querySelectorAll('.delete-article-btn').forEach(btn => {
    btn.addEventListener('click', function (ev) {
      const form = btn.closest('form');
      if (!form) return; // safety
      ev.preventDefault();

      // ensure auth token exists in form before building FormData
      ensureHiddenInput(form, 'authenticity_token', csrfToken());

      // prefer fetch path
      sendFormDataWithCsrf(form, null);
    });
  });

  // --- Safety: for any non-GET form submission, ensure authenticity_token exists ---
  document.addEventListener('submit', function (ev) {
    const form = ev.target;
    if (!(form instanceof HTMLFormElement)) return;
    const method = (form.getAttribute('method') || 'GET').toUpperCase();
    if (method !== 'GET') {
      ensureHiddenInput(form, 'authenticity_token', csrfToken());
    }
  }, true);
});
 