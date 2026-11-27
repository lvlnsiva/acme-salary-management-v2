import { useCallback, useEffect, useState } from 'react'

const API = import.meta.env.VITE_API_URL || '/api/v1'
const blankEmployee = {
  employee_number: '', first_name: '', last_name: '', email: '',
  country_id: '', department_id: '', job_title: '',
  employment_status: 'active', last_working_date: '',
}
const blankSalary = { amount: '', currency_code: 'INR', effective_from: '', effective_to: '' }

async function request(path, options = {}) {
  const response = await fetch(`${API}${path}`, {
    ...options,
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
  })
  if (response.status === 204) return null
  const body = await response.json().catch(() => ({}))
  if (!response.ok) {
    const messages = body.errors || body.error || ['Request failed']
    throw new Error(Array.isArray(messages) ? messages.join(', ') : messages)
  }
  return body
}

function App() {
  const [employees, setEmployees] = useState([])
  const [meta, setMeta] = useState({ page: 1, total_pages: 1, total_count: 0 })
  const [countries, setCountries] = useState([])
  const [departments, setDepartments] = useState([])
  const [insights, setInsights] = useState(null)
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('')
  const [country, setCountry] = useState('')
  const [department, setDepartment] = useState('')
  const [page, setPage] = useState(1)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [employee, setEmployee] = useState(null)
  const [employeeForm, setEmployeeForm] = useState(null)
  const [salaryForm, setSalaryForm] = useState(null)
  const [saving, setSaving] = useState(false)

  const loadLookups = useCallback(async () => {
    const [countryResult, departmentResult] = await Promise.all([
      request('/countries'), request('/departments'),
    ])
    setCountries(countryResult.data)
    setDepartments(departmentResult.data)
  }, [])

  const loadInsights = useCallback(async () => {
    const result = await request('/insights')
    setInsights(result.data)
  }, [])

  const loadEmployees = useCallback(async () => {
    setLoading(true)
    setError('')
    const params = new URLSearchParams({ page: String(page), per_page: '20' })
    if (search.trim()) params.set('search', search.trim())
    if (status) params.set('employment_status', status)
    if (country) params.set('country', country)
    if (department) params.set('department', department)
    try {
      const result = await request(`/employees?${params}`)
      setEmployees(result.data)
      setMeta(result.meta)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }, [page, search, status, country, department])

  useEffect(() => {
    Promise.all([loadLookups(), loadInsights()]).catch(err => setError(err.message))
  }, [loadLookups, loadInsights])

  useEffect(() => { loadEmployees() }, [loadEmployees])

  async function refresh() {
    await Promise.all([loadEmployees(), loadInsights()])
  }

  async function saveEmployee(event) {
    event.preventDefault()
    setSaving(true)
    setError('')
    try {
      const editing = employeeForm.id
      const payload = { ...employeeForm }
      delete payload.id
      payload.country_id = Number(payload.country_id)
      payload.department_id = Number(payload.department_id)
      if (!payload.last_working_date) payload.last_working_date = null
      await request(editing ? `/employees/${editing}` : '/employees', {
        method: editing ? 'PATCH' : 'POST',
        body: JSON.stringify({ employee: payload }),
      })
      setEmployeeForm(null)
      await refresh()
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  async function openDetails(row) {
    try {
      setEmployee(await request(`/employees/${row.id}`))
    } catch (err) { setError(err.message) }
  }

  async function saveSalary(event) {
    event.preventDefault()
    setSaving(true)
    setError('')
    try {
      await request(`/employees/${salaryForm.employee_id}/salaries`, {
        method: 'POST',
        body: JSON.stringify({ salary: {
          amount: salaryForm.amount, currency_code: salaryForm.currency_code,
          effective_from: salaryForm.effective_from,
          effective_to: salaryForm.effective_to || null,
        } }),
      })
      setSalaryForm(null)
      await openDetails({ id: salaryForm.employee_id })
      await refresh()
    } catch (err) {
      setError(err.message)
    } finally { setSaving(false) }
  }

  async function deleteEmployee(row) {
    if (!window.confirm(`Delete ${row.first_name} ${row.last_name}? Employees with salary history cannot be deleted.`)) return
    try {
      await request(`/employees/${row.id}`, { method: 'DELETE' })
      await refresh()
    } catch (err) { setError(err.message) }
  }

  function editEmployee(row) {
    setEmployeeForm({
      ...blankEmployee, ...row,
      country_id: String(row.country_id),
      department_id: String(row.department_id),
      last_working_date: row.last_working_date || '',
    })
  }

  const count = insights?.headcount || {}
  const currencyTotals = insights?.current_salary || []

  return <div className="app-shell">
    <header className="topbar">
      <div className="brand"><span className="brand-icon">A</span><div><b>ACME</b><small>Salary Management</small></div></div>
      <span className="role">HR Manager</span>
    </header>
    <main className="container">
      <section className="page-heading"><div><p className="eyebrow">PEOPLE OPERATIONS</p><h1>Employee overview</h1><p className="muted">Manage employee records, compensation and salary history.</p></div>
        <button className="primary" onClick={() => setEmployeeForm({ ...blankEmployee })}>+ Add employee</button>
      </section>
      {error && <div className="alert" role="alert">{error}<button onClick={() => setError('')}>Dismiss</button></div>}
      <section className="metrics">
        <Metric label="Total employees" value={count.total ?? meta.total_count} note="All employee records" />
        <Metric label="Active employees" value={count.active ?? '—'} note="Currently employed" />
        <Metric label="Inactive employees" value={count.inactive ?? '—'} note="Former employees retained" />
      </section>
      {currencyTotals.length > 0 && <section className="panel insights"><div className="panel-title"><div><h2>Current compensation</h2><p className="muted">Grouped by currency. Values are not converted across currencies.</p></div></div><div className="currency-grid">{currencyTotals.map(item => <div className="currency-card" key={item.currency_code}><span>{item.currency_code}</span><b>{Number(item.average_amount || 0).toLocaleString(undefined, { maximumFractionDigits: 2 })}</b><small>Average · {item.employee_count} employees</small></div>)}</div></section>}
      <section className="panel">
        <div className="panel-title"><div><h2>Employees</h2><p className="muted">{meta.total_count?.toLocaleString()} records</p></div></div>
        <div className="filters">
          <input aria-label="Search employees" placeholder="Search name, employee number or email" value={search} onChange={e => { setSearch(e.target.value); setPage(1) }} />
          <select aria-label="Employment status" value={status} onChange={e => { setStatus(e.target.value); setPage(1) }}><option value="">All statuses</option><option value="active">Active</option><option value="inactive">Inactive</option></select>
          <select aria-label="Country" value={country} onChange={e => { setCountry(e.target.value); setPage(1) }}><option value="">All countries</option>{countries.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}</select>
          <select aria-label="Department" value={department} onChange={e => { setDepartment(e.target.value); setPage(1) }}><option value="">All departments</option>{departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}</select>
          <button className="secondary" onClick={() => { setSearch(''); setStatus(''); setCountry(''); setDepartment(''); setPage(1) }}>Clear</button>
        </div>
        <div className="table-wrap"><table><thead><tr><th>Employee</th><th>Country</th><th>Department</th><th>Job title</th><th>Current salary</th><th>Status</th><th>Actions</th></tr></thead>
          <tbody>{loading ? <tr><td colSpan="7" className="empty">Loading employees…</td></tr> : employees.length === 0 ? <tr><td colSpan="7" className="empty">No employees found.</td></tr> : employees.map(row => <tr key={row.id}>
            <td><button className="link" onClick={() => openDetails(row)}>{row.first_name} {row.last_name}</button><small className="subline">{row.employee_number} · {row.email}</small></td>
            <td>{row.country?.name}</td><td>{row.department?.name}</td><td>{row.job_title}</td>
            <td>{row.current_salary ? `${row.current_salary.currency_code} ${Number(row.current_salary.amount).toLocaleString()}` : '—'}</td>
            <td><span className={`status ${row.employment_status}`}>{row.employment_status}</span></td>
            <td className="actions"><button className="text-button" onClick={() => editEmployee(row)}>Edit</button><button className="text-button danger" onClick={() => deleteEmployee(row)}>Delete</button></td>
          </tr>)}</tbody></table></div>
        <footer className="pagination"><span>Showing {employees.length} of {meta.total_count || 0}</span><div><button className="secondary" disabled={page <= 1} onClick={() => setPage(p => p - 1)}>Previous</button><span>Page {meta.page || page} / {Math.max(meta.total_pages || 1, 1)}</span><button className="secondary" disabled={page >= (meta.total_pages || 1)} onClick={() => setPage(p => p + 1)}>Next</button></div></footer>
      </section>
    </main>

    {employeeForm && <Modal title={employeeForm.id ? 'Edit employee' : 'Add employee'} onClose={() => setEmployeeForm(null)}>
      <form onSubmit={saveEmployee} className="form-grid">
        <Field label="Employee number"><input required value={employeeForm.employee_number} onChange={e => setEmployeeForm({ ...employeeForm, employee_number: e.target.value })} /></Field>
        <Field label="First name"><input required value={employeeForm.first_name} onChange={e => setEmployeeForm({ ...employeeForm, first_name: e.target.value })} /></Field>
        <Field label="Last name"><input required value={employeeForm.last_name} onChange={e => setEmployeeForm({ ...employeeForm, last_name: e.target.value })} /></Field>
        <Field label="Email"><input required type="email" value={employeeForm.email} onChange={e => setEmployeeForm({ ...employeeForm, email: e.target.value })} /></Field>
        <Field label="Country"><select required value={employeeForm.country_id} onChange={e => setEmployeeForm({ ...employeeForm, country_id: e.target.value })}><option value="">Choose country</option>{countries.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}</select></Field>
        <Field label="Department"><select required value={employeeForm.department_id} onChange={e => setEmployeeForm({ ...employeeForm, department_id: e.target.value })}><option value="">Choose department</option>{departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}</select></Field>
        <Field label="Job title"><input required value={employeeForm.job_title} onChange={e => setEmployeeForm({ ...employeeForm, job_title: e.target.value })} /></Field>
        <Field label="Employment status"><select value={employeeForm.employment_status} onChange={e => setEmployeeForm({ ...employeeForm, employment_status: e.target.value })}><option value="active">Active</option><option value="inactive">Inactive</option></select></Field>
        {employeeForm.employment_status === 'inactive' && <Field label="Last working date"><input type="date" value={employeeForm.last_working_date || ''} onChange={e => setEmployeeForm({ ...employeeForm, last_working_date: e.target.value })} /></Field>}
        <div className="form-actions"><button type="button" className="secondary" onClick={() => setEmployeeForm(null)}>Cancel</button><button className="primary" disabled={saving}>{saving ? 'Saving…' : 'Save employee'}</button></div>
      </form>
    </Modal>}

    {employee && <Modal title={`${employee.first_name} ${employee.last_name}`} onClose={() => setEmployee(null)}>
      <div className="detail-grid"><Detail label="Employee number" value={employee.employee_number}/><Detail label="Email" value={employee.email}/><Detail label="Country" value={employee.country?.name}/><Detail label="Department" value={employee.department?.name}/><Detail label="Job title" value={employee.job_title}/><Detail label="Status" value={employee.employment_status}/><Detail label="Last working date" value={employee.last_working_date || '—'}/></div>
      <div className="salary-heading"><h3>Salary history</h3><button className="primary small" onClick={() => setSalaryForm({ ...blankSalary, employee_id: employee.id })}>Add salary</button></div>
      {employee.salaries?.length ? <div className="history">{employee.salaries.map(s => <div className="history-row" key={s.id}><b>{s.currency_code} {Number(s.amount).toLocaleString()}</b><span>{s.effective_from} — {s.effective_to || 'Ongoing'}</span></div>)}</div> : <p className="muted">No salary history available.</p>}
    </Modal>}

    {salaryForm && <Modal title="Add salary record" onClose={() => setSalaryForm(null)}>
      <form className="form-grid" onSubmit={saveSalary}>
        <Field label="Amount"><input type="number" min="0.01" step="0.01" required value={salaryForm.amount} onChange={e => setSalaryForm({ ...salaryForm, amount: e.target.value })}/></Field>
        <Field label="Currency"><select value={salaryForm.currency_code} onChange={e => setSalaryForm({ ...salaryForm, currency_code: e.target.value })}>{['INR','USD','GBP','EUR','CAD','AUD','SGD','AED'].map(c => <option key={c}>{c}</option>)}</select></Field>
        <Field label="Effective from"><input type="date" required value={salaryForm.effective_from} onChange={e => setSalaryForm({ ...salaryForm, effective_from: e.target.value })}/></Field>
        <Field label="Effective to (optional)"><input type="date" value={salaryForm.effective_to} onChange={e => setSalaryForm({ ...salaryForm, effective_to: e.target.value })}/></Field>
        <div className="form-actions"><button type="button" className="secondary" onClick={() => setSalaryForm(null)}>Cancel</button><button className="primary" disabled={saving}>{saving ? 'Saving…' : 'Save salary'}</button></div>
      </form>
    </Modal>}
  </div>
}

function Metric({ label, value, note }) { return <div className="metric"><span>{label}</span><b>{value}</b><small>{note}</small></div> }
function Field({ label, children }) { return <label className="field"><span>{label}</span>{children}</label> }
function Detail({ label, value }) { return <div className="detail"><small>{label}</small><b>{value || '—'}</b></div> }
function Modal({ title, onClose, children }) { return <div className="overlay" onMouseDown={e => { if (e.target === e.currentTarget) onClose() }}><section className="modal" role="dialog" aria-modal="true" aria-label={title}><header><h2>{title}</h2><button className="close" onClick={onClose} aria-label="Close">×</button></header>{children}</section></div> }

export default App
