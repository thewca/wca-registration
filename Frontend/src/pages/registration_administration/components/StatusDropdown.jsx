import React from 'react'

const options = ['waiting', 'accepted', 'deleted']
export default function StatusDropdown({ status, setStatus }) {
  return (
    <select onChange={(e) => setStatus(e.target.value)} value={status}>
      {options.map((opt) => (
        <option key={opt}>{opt}</option>
      ))}
    </select>
  )
}
