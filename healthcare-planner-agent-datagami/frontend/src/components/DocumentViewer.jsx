import React, { useState } from 'react';

const DocumentViewer = ({ document, onClear, title = 'Generated Document' }) => {
  const [copied, setCopied] = useState(false);

  if (!document) return null;

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(document.content || '');
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-4">
      <div className="flex items-start justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white">{title}</h3>
          {document.documentId && (
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">ID: <span className="font-mono text-sm">{document.documentId}</span></p>
          )}
        </div>
        <div className="flex items-center gap-2">
          <button onClick={handleCopy} className="px-3 py-1 bg-blue-600 text-white rounded-md text-sm">
            {copied ? 'Copied' : 'Copy'}
          </button>
          <button onClick={onClear} className="px-3 py-1 bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-md text-sm">
            Close
          </button>
        </div>
      </div>

      <div className="mt-4 text-sm text-gray-800 dark:text-gray-200 whitespace-pre-wrap">
        {document.content}
      </div>
    </div>
  );
};

export default DocumentViewer;
