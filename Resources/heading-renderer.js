marked.use({
    renderer: {
        heading(text, level, raw) {
            // Reset anchor tracking on each render to ensure consistency
            if (!window._headingAnchors) window._headingAnchors = [];

            var cleanText = (raw || text || '')
                .replace(/<[^>]+>/g, '')
                .replace(/&amp;/g, '&')
                .replace(/&lt;/g, '<')
                .replace(/&gt;/g, '>')
                .replace(/&quot;/g, '"')
                .replace(/&#39;/g, "'");
            var baseAnchor = cleanText.toLowerCase().replace(/ /g, '-');

            // Count occurrences of this base anchor
            var count = 0;
            for (var i = 0; i < window._headingAnchors.length; i++) {
                if (window._headingAnchors[i] === baseAnchor) count++;
            }

            // Add to tracking array
            window._headingAnchors.push(baseAnchor);

            // Generate anchor: no suffix for first, -1, -2, etc for duplicates
            var anchor = baseAnchor;
            if (count > 0) {
                anchor = baseAnchor + '-' + count;
            }

            return '<h' + level + ' id="' + anchor + '">' + text + '</h' + level + '>';
        }
    }
});