import * as vscode from 'vscode';
import { PlotJsonEditorProvider } from './plotJsonEditor';

class HelloWorldProvider implements vscode.TreeDataProvider<string> {
    getTreeItem(element: string): vscode.TreeItem {
        return {
            label: element,
            collapsibleState: vscode.TreeItemCollapsibleState.None
        };
    }

    getChildren(element?: string): Thenable<string[]> {
        if (!element) {
            return Promise.resolve(['Hello World from Custom View!', 'Extension is working properly']);
        }
        return Promise.resolve([]);
    }
}

export function activate(context: vscode.ExtensionContext) {
    console.log('Codespace Extension is now active!');
    
    vscode.window.showInformationMessage('Codespace Extension has been activated successfully!');

    const disposable = vscode.commands.registerCommand('codespace-extension.helloWorld', () => {
        vscode.window.showInformationMessage('Hello World from Codespace Extension!');
    });

    const provider = new HelloWorldProvider();
    vscode.window.createTreeView('codespace-extension.helloView', { treeDataProvider: provider });

    // Register the custom plot JSON editor
    context.subscriptions.push(PlotJsonEditorProvider.register(context));

    context.subscriptions.push(disposable);
}

export function deactivate() {
    console.log('Codespace Extension is now deactivated');
}