# Exam Questions Page UX Plan

This note captures the agreed work for the lecturer Exam Questions page.

## Goal

Build a cleaner question-paper page where the lecturer does not see every question field at once. Question formats should remain folded. When a lecturer selects or opens a format, only that format's fields should appear.

## Agreed page flow

1. Paper setup
   - Course
   - Exam title
   - Duration
   - Reviewer / Exam Officer ID
   - Description
   - Student instructions
   - Auto-mark setting

2. Folded question formats
   - Single answer
   - Multiple answers
   - Fill in the blank
   - Essay / Theory
   - Drag and drop
   - Picture question
   - File upload / Practical

3. Question list
   - Each added question appears as a folded card.
   - The lecturer can expand only the question being edited.
   - Each question card shows type, marks, topic/CLO, completion status, duplicate, and remove actions.

4. Review before submission
   - The lecturer must review the full paper on a separate review view before submitting.
   - The review view shows paper summary, course, instructions, duration, total marks, and a question-by-question preview.

## Multiple-answer support

The new page supports `multiple_choice` questions. The lecturer can tick more than one correct option and can enable partial marking in the question card. The payload stores both `correct_answers` and the `partial_marking` setting.

## Payload direction

The UI sends version 2 question payloads using the names expected by the lecturer assessment engine:

- `single_choice`
- `multiple_choice`
- `fill_blank`
- `essay`
- `drag_drop`
- `image_question`
- `file_upload`

The existing API bridge is preserved so the page remains compatible with the current admin UI service while the backend assessment endpoints continue to mature.

## UX decisions

- Keep the page calm and simple.
- Avoid showing all fields at once.
- Use professional wording: question paper, review, marking guide, reviewer, Exam Officer.
- Do not submit directly from the builder page; use the review page first.
- Show validation messages before review so lecturers fix missing question text, marks, options, and answer keys early.
