# Alogyan Interactive Whiteboard (Excalidraw Engine) — Integration & Self-Hosting Guide

This guide explains how **Excalidraw** is integrated into **Alogyan Teachers CMS** as the primary interactive whiteboard for teachers, tutors, and coaching centers to conduct visual lectures, sketch diagrams, write mathematical formulas, upload images, and automatically publish session notes to batches.

---

## 1. Overview & Architecture

Alogyan Teachers CMS embeds **Excalidraw** natively directly within the dashboard at `/whiteboard`.

```
                      +---------------------------------------+
                      |       Alogyan Teachers CMS           |
                      |   (Next.js 16 + Firebase + Tailwind)  |
                      +-------------------+-------------------+
                                          |
                        Native Embedded Excalidraw Component
                                          |
                                          v
                      +---------------------------------------+
                      |    Excalidraw Whiteboard Engine       |
                      |                                       |
                      |  • Infinite hand-drawn sketch canvas  |
                      |  • Full drawable toolkit (pen/shapes) |
                      |  • Direct Image & File Upload         |
                      |  • Batch-specific scene persistence   |
                      |  • 1-Click Export to PNG/SVG/JSON     |
                      |  • 1-Click "Save to Batch Notes"      |
                      +-------------------+-------------------+
                                          |
                      +-------------------+-------------------+
                      |   Firestore & Storage Cloud Sync     |
                      |  • Snapshot uploaded to Storage       |
                      |  • Note registered under Batch Notes  |
                      +---------------------------------------+
```

When teachers finish a whiteboard explanation or lecture, they click **Save to Batch Notes** in Alogyan CMS. A high-resolution PNG snapshot is generated via `exportToBlob` and saved to Firebase Storage and Firestore `notes`, making it immediately accessible to enrolled students in that batch under `/notes`.

---

## 2. Features: Upload & Drawable

### A. Drawable (Full Teaching Canvas)
- **Freedraw / Pen**: Fluid handwriting with pressure simulation, thickness adjustments, and color palette.
- **Shapes**: Rectangles, Diamonds, Ellipses, Lines, and Arrows (curved or straight).
- **Text & Notes**: Handwritten fonts for natural classroom feels.
- **Highlighter / Laser Pointer**: Draw attention to key formulas during live sessions without altering the underlying sketch.
- **Eraser**: Fast element and stroke erasure.
- **Styles**: Custom rough-sketch appearance, stroke widths, fill patterns (hachure, cross-hatch, solid), and opacity.

### B. Upload (Worksheets, Diagrams, & Scenes)
- **Insert / Upload Image**: Teachers can upload PNG, JPEG, SVG, GIF, or WebP files onto the canvas by clicking the **Upload Image** button, pressing `9`, or dragging and dropping files directly onto the board.
- **Upload Existing Scene (`.excalidraw`)**: Import previously prepared lecture materials or templates.
- **Batch-Specific Local Auto-Save**: Each batch has dedicated canvas state saved locally so switching batches restores the exact board for that class.

---

## 3. Optional: Self-Hosting a Custom Excalidraw Server

While Alogyan CMS runs Excalidraw natively in the browser without requiring external servers, you can also self-host an Excalidraw web instance or collaboration backend.

### Option A: Official Excalidraw Docker Image

1. **Run Container**:
   ```bash
   docker run -d \
     --name alogyan-excalidraw \
     --restart unless-stopped \
     -p 8080:80 \
     excalidraw/excalidraw:latest
   ```

2. **Verify Container**:
   ```bash
   curl -I http://localhost:8080
   ```

### Option B: Build from Source (PM2 / Node)

1. **Clone repository**:
   ```bash
   git clone https://github.com/excalidraw/excalidraw.git /var/www/whiteboard
   cd /var/www/whiteboard
   yarn install
   yarn build
   ```

2. **Serve with PM2**:
   ```bash
   pm2 serve build 8080 --name "excalidraw-whiteboard" --spa
   pm2 save
   ```

---

## 4. Configuration in Alogyan CMS

1. **Environment Variable**:
   In `alogyan-teachers-cms/.env.local`:
   ```env
   NEXT_PUBLIC_WHITEBOARD_URL=https://excalidraw.com
   ```
2. **In-App Server Settings**:
   Teachers and administrators can click **Server Settings** on `/whiteboard` to specify a self-hosted Excalidraw domain or reset to the embedded native engine.
