const $ = selector => document.querySelector(selector);
const storyInput = $('#storyInput');
storyInput.value = sessionStorage.getItem('puppetStory') || '';

function refreshEstimate() {
  const text = storyInput.value.trim();
  const words = text.match(/\S+/g) || [];
  $('#wordCount').textContent = `${words.length} words`;
  if (!text) {
    $('#estimateText').textContent = 'Paste a story to estimate its suitability.';
    return;
  }
  const sentences = (text.match(/[^.!?]+[.!?]+|[^.!?]+$/g) || []).filter(s => s.trim());
  const names = [...new Set((text.match(/\b[A-Z][a-z]{2,}\b/g) || []).filter(name => !/^(The|And|But|Once|When|After|Before|Soon|There|Their|Then|Every|Finally|One|At|In|By|As|It|She|He|They|This|That)$/.test(name)))];
  const dialogue = (text.match(/[“"][^”"]{3,}[”"]/g) || []).length;
  const cues = (text.match(/\b(said|asked|replied|whispered|shouted|told|called|answered|helped|found|met|went|came|ran|walked|carried|returned|shared)\b/gi) || []).length;
  let percent = 42 + Math.min(20, names.length * 7) + Math.min(18, dialogue * 6) + Math.min(16, cues * 2);
  if (words.length > 160) percent -= 18;
  percent = Math.max(25, Math.min(92, percent));
  const minutes = Math.max(1, Math.ceil(words.length / 115));
  $('#estimateText').textContent = `About ${percent}% estimated suitability · ${names.length} possible named characters · ${sentences.length} possible acts · roughly ${minutes} minute${minutes === 1 ? '' : 's'} of narration${words.length > 850 ? ' · very long stories are shortened toward 8 minutes' : ''}. This is a rough rules-based estimate, not an AI understanding of the story.`;
}

$('#fileInput').addEventListener('change', event => {
  const file = event.target.files?.[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    storyInput.value = String(reader.result || '');
    refreshEstimate();
  };
  reader.readAsText(file);
});
storyInput.addEventListener('input', refreshEstimate);
$('#continue').addEventListener('click', () => {
  const text = storyInput.value.trim();
  if (!text) {
    $('#toast').textContent = 'Paste a story or open a text file first.';
    $('#toast').classList.add('show');
    setTimeout(() => $('#toast').classList.remove('show'), 3000);
    storyInput.focus();
    return;
  }
  sessionStorage.setItem('puppetStory', text);
  location.href = 'puppet-show.html';
});
refreshEstimate();
