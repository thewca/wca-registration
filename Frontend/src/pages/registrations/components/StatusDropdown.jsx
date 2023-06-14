import React from 'react'

export default function StatusDropdown({ status, setStatus }) {
  const options = ['waiting', 'accepted', 'deleted']
  return (
    <select onChange={(e) => setStatus(e.target.value)} value={status}>
      {options.map((opt) => (
        <option key={opt}>{opt}</option>
      ))}
    </select>
  )
}
