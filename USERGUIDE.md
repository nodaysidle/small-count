# Small Count User Guide

Small Count is a private, local-only manual counter for the macOS menu bar. It requires macOS 15 or later.

## Start

Open `/Applications/Small Count.app`. Select the count icon in the menu bar. The app's Finder icon is a dark navy rounded square with three count bars and a coral add badge.

## Create and manage counters

1. Choose **Settings…** (`Command-,`).
2. Enter a counter name and optional color, then choose **Create**.
3. Edit an active counter inline and choose **Save**.
4. Choose **Archive** to hide a counter from the menu. In **Archived Counters**, choose **Restore** to return it. Archive and restore never delete history.

## Record and view totals

Open the menu and choose an active counter row. One event is recorded at the current local time, and the current local-day total updates.

## Export history

In Settings, choose **Export…** beside a counter, select a destination, and save. Cancelling the save panel writes nothing. The UTF-8 Markdown export contains that counter and its complete ordered event history.

## Recovery and privacy

If an operation fails, Small Count keeps the last valid state and shows **Retry**. All data remains in the app-owned local SwiftData store. Small Count has no networking, accounts, analytics, notifications, global shortcuts, or deletion.

Choose **Quit** (`Command-Q`) to exit.
